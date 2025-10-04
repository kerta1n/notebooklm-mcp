FROM python:3.11-slim-trixie

ENV DEBIAN_FRONTEND=noninteractive
ENV CHROME_HEADLESS=1
ENV CHROME_ARGS="--no-sandbox --disable-dev-shm-usage --disable-gpu"
ENV CHROME_BIN=/usr/bin/google-chrome-stable
ENV DISPLAY=:99

# Install system dependencies for Chrome and UV
RUN apt-get update && apt-get install -y \
    wget \
    gnupg2 \
    apt-transport-https \
    ca-certificates \
    curl \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install UV Python manager
RUN pip install uv

# Install Google Chrome
# https://www.baeldung.com/ops/docker-google-chrome-headless#bd-writing-a-dockerfile-to-run-headless-chrome

### There seems to be an issue with how the container recognizes Chrome. With this RUN line in, you get "Failed to initialize client: Message: session not created: cannot connect to chrome at"
### Commenting this out will STILL result in "Could not determine browser executable." by notebooklm_mcp.server:_ensure_client:81, EVEN IF you patch the client.py file to explicitly use the browser exec path.
RUN apt-get update && \
    curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-linux-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-linux-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && apt-get install -y --no-install-recommends google-chrome-stable && \
    rm -rf /var/lib/apt/lists/*

# Install ChromeDriver
RUN CHROMEDRIVER_VERSION=`curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE` && \
    wget -O /tmp/chromedriver.zip http://chromedriver.storage.googleapis.com/$CHROMEDRIVER_VERSION/chromedriver_linux64.zip && \
    unzip /tmp/chromedriver.zip chromedriver -d /usr/local/bin/ && \
    rm /tmp/chromedriver.zip && \
    chmod +x /usr/local/bin/chromedriver

# Create non-root user for security (do this BEFORE setting up the app)
RUN groupadd -r notebooklm && useradd -r -g notebooklm -m -d /home/notebooklm notebooklm

# Set up working directory
WORKDIR /app
RUN chown -R notebooklm:notebooklm /app

# Switch to non-root user BEFORE copying files and installing
USER notebooklm

# Copy project files for UV
COPY --chown=notebooklm:notebooklm pyproject.toml uv.lock ./

# Copy source code
COPY --chown=notebooklm:notebooklm src/ ./src/
COPY --chown=notebooklm:notebooklm examples/ ./examples/

# Install dependencies with UV
RUN uv sync --all-groups

# Install package with UV
RUN uv pip install -e .

# Create chrome profile directory with proper permissions
RUN mkdir -p /app/chrome_profile && chown -R notebooklm:notebooklm /app/chrome_profile

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
