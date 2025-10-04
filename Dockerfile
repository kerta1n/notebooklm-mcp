FROM python:3.11-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV CHROME_HEADLESS=1
ENV CHROME_ARGS="--no-sandbox --disable-dev-shm-usage --disable-gpu"
ENV CHROME_BIN=/usr/bin/google-chrome-stable
ENV DISPLAY=:99

# Install system dependencies for Chrome and UV
RUN apt-get update && apt-get install -y \
    wget \
    gnupg2 \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    curl \
    unzip \
    fonts-liberation \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libatspi2.0-0 \
    libcups2 \
    libdbus-1-3 \
    libdrm2 \
    libgbm1 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libwayland-client0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxkbcommon0 \
    libxrandr2 \
    xdg-utils \
    libu2f-udev \
    libvulkan1 \

    && rm -rf /var/lib/apt/lists/*

# Install UV Python manager
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.cargo/bin:$PATH"

# Install Google Chrome
RUN wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update \
    && apt-get install -y google-chrome-stable \
    && which google-chrome-stable \
    && sleep 3 \
    && google-chrome-stable --version \
    && sleep 3 \
    && ln -sf /usr/bin/google-chrome-stable /usr/bin/google-chrome \
    && rm -rf /var/lib/apt/lists/*

# Install ChromeDriver
RUN CHROMEDRIVER_VERSION=`curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE` && \
    wget -O /tmp/chromedriver.zip http://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_linux64.zip && \
    unzip /tmp/chromedriver.zip chromedriver -d /usr/local/bin/ && \
    rm /tmp/chromedriver.zip && \
    chmod +x /usr/local/bin/chromedriver

# Set up working directory
WORKDIR /app

# Create non-root user for security
RUN groupadd -r notebooklm && useradd -r -g notebooklm notebooklm
RUN chown -R notebooklm:notebooklm /app

# Copy project files for UV
COPY pyproject.toml uv.lock ./

# Install dependencies with UV
RUN uv sync --all-groups

# Copy source code
COPY src/ ./src/
COPY examples/ ./examples/

# Install package with UV
RUN uv pip install -e .

# Create chrome profile directory with proper permissions
RUN mkdir -p /app/chrome_profile && chown -R notebooklm:notebooklm /app/chrome_profile

# Switch to non-root user
USER notebooklm

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV UV_PYTHON=python3.11
ENV NOTEBOOKLM_CONFIG_FILE=/app/notebooklm-config.json

# Expose MCP ports
EXPOSE 8001 8002

# Health check with UV
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD uv run python -c "from notebooklm_mcp.config import ServerConfig; print('Config valid') if ServerConfig.from_file('/app/notebooklm-config.json') else exit(1)" || exit 1

# Default command - STDIO mode for MCP
CMD ["uv", "run", "python", "-m", "notebooklm_mcp.cli", "--config", "/app/notebooklm-config.json", "server"]
