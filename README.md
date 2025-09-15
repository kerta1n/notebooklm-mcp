# 🤖 NotebookLM MCP Server

[![PyPI version](https://badge.fury.io/py/notebooklm-mcp.svg)](https://badge.fury.io/py/notebooklm-mcp)
[![Python 3.10+](https://img.shields.io/badge/python-3.10+-blue.svg)](https://www.python.org/downloads/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Code style: black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black)
[![Tests](https://github.com/khengyun/notebooklm-mcp/actions/workflows/test.yml/badge.svg)](https://github.com/khengyun/notebooklm-mcp/actions)
[![codecov](https://codecov.io/gh/khengyun/notebooklm-mcp/graph/badge.svg)](https://codecov.io/gh/khengyun/notebooklm-mcp)

Professional **Model Context Protocol (MCP) server** for automating interactions with Google's **NotebookLM**.

## 🚀 **Quick Start (2 Commands)**

### **Step 1: Initialize**

```bash
notebooklm-mcp init https://notebooklm.google.com/notebook/YOUR_NOTEBOOK_ID
```

**What this does:**

- ✅ Extracts notebook ID from URL
- ✅ Creates `notebooklm-config.json`
- ✅ Sets up browser profile
- ✅ Tests authentication
- ✅ Optimizes for headless mode

### **Step 2: Start Server**

```bash
notebooklm-mcp --config notebooklm-config.json server
```

**That's it!** Your MCP server is ready for AutoGen, Copilot, or any MCP client.

---

## 📦 **Installation**

```bash
pip install notebooklm-mcp
```

## ✨ **Key Features**

- **🔐 One-time setup** - Login once, auto-authenticate forever
- **🚀 MCP Protocol** - Works with AutoGen, GitHub Copilot, and all MCP clients
- **⚡ Streaming Support** - Real-time AI response handling
- **🛡️ Anti-Detection** - Uses `undetected-chromedriver` for Google compatibility
- **📱 Headless Mode** - Optimized for production deployment

## 💻 **MCP Integration Examples**

### **AutoGen Integration**

```python
from autogen_ext.tools.mcp import McpWorkbench, StdioServerParams

# Configure MCP server with correct syntax
params = StdioServerParams(
    command="notebooklm-mcp",
    args=["--config", "notebooklm-config.json", "server", "--headless"]
)

# Create MCP workbench
workbench = McpWorkbench(params)

# Use tools
await workbench.call_tool("chat_with_notebook", {
    "message": "Analyze the main themes in this research paper",
    "max_wait": 60
})
```

### **GitHub Copilot Integration**

Add to your VS Code `settings.json`:

```json
{
  "github.copilot.advanced": {
    "mcp": {
      "servers": {
        "notebooklm": {
          "command": "notebooklm-mcp",
          "args": ["--config", "notebooklm-config.json", "server", "--headless"]
        }
      }
    }
  }
}
```

## 🛠️ **MCP Tools Available**

| Tool | Arguments | Description |
|------|-----------|-------------|
| `healthcheck` | None | Server health status |
| `send_chat_message` | `message: str` | Send message to NotebookLM |
| `get_chat_response` | `wait_for_completion: bool`, `max_wait: int` | Get response with streaming |
| `get_quick_response` | None | Get current response immediately |
| `chat_with_notebook` | `message: str`, `max_wait: int` | Combined send + receive |
| `navigate_to_notebook` | `notebook_id: str` | Navigate to specific notebook |

## 🐳 **Docker Deployment**

```bash
# Quick start with Docker
docker run -e NOTEBOOKLM_NOTEBOOK_ID="YOUR_ID" notebooklm-mcp

# Or use docker-compose
docker-compose up -d
```

## 📄 **License**

MIT License - see [LICENSE](LICENSE) file for details.

## 🆘 **Support**

- **Issues**: [GitHub Issues](https://github.com/khengyun/notebooklm-mcp/issues)
- **Discussions**: [GitHub Discussions](https://github.com/khengyun/notebooklm-mcp/discussions)

---

**⭐ If this project helps you, please give it a star!**

## 📖 **Usage Examples**

### **Python API**

```python
import asyncio
from notebooklm_mcp import NotebookLMClient, ServerConfig

async def main():
    # Configure client
    config = ServerConfig(
        default_notebook_id="your-notebook-id",
        headless=True,
        debug=True
    )

    client = NotebookLMClient(config)

    try:
        # Start browser with persistent session
        await client.start()

        # Authenticate (automatic with saved session)
        await client.authenticate()

        # Send message and get streaming response
        await client.send_message("What are the key insights from this document?")
        response = await client.get_response(wait_for_completion=True)

        print(f"NotebookLM: {response}")

    finally:
        await client.close()

asyncio.run(main())
```

### **MCP Integration with AutoGen**

```python
from autogen_ext.tools.mcp import McpWorkbench, StdioServerParams

# Configure MCP server
params = StdioServerParams(
    command="notebooklm-mcp",
    args=["server", "--notebook", "your-notebook-id", "--headless"]
)

# Create MCP workbench
workbench = McpWorkbench(params)

# Use tools
await workbench.call_tool("chat_with_notebook", {
    "message": "Analyze the main themes in this research paper",
    "max_wait": 60
})
```

## 🛠️ **Advanced Configuration**

### **Environment Variables**

```bash
# Core settings
export NOTEBOOKLM_NOTEBOOK_ID="your-notebook-id"
export NOTEBOOKLM_HEADLESS="true"
export NOTEBOOKLM_DEBUG="false"
export NOTEBOOKLM_TIMEOUT="60"

# Authentication
export NOTEBOOKLM_PROFILE_DIR="./chrome_profile"
export NOTEBOOKLM_PERSISTENT_SESSION="true"

# Streaming
export NOTEBOOKLM_STREAMING_TIMEOUT="60"
```

## 📊 **MCP Tools Reference**

| Tool | Arguments | Description |
|------|-----------|-------------|
| `healthcheck` | None | Server health status |
| `send_chat_message` | `message: str` | Send message to NotebookLM |
| `get_chat_response` | `wait_for_completion: bool`, `max_wait: int` | Get response with streaming support |
| `get_quick_response` | None | Get current response immediately |
| `chat_with_notebook` | `message: str`, `max_wait: int` | Combined send + receive operation |
| `navigate_to_notebook` | `notebook_id: str` | Navigate to specific notebook |
| `upload_document` | `file_path: str` | Upload document to notebook |
| `list_notebooks` | None | List available notebooks |
| `create_notebook` | `title: str` | Create new notebook |

## 🔧 **Development**

### **Setup Development Environment**

```bash
# Clone repository
git clone https://github.com/notebooklm-mcp/notebooklm-mcp.git
cd notebooklm-mcp

# Install development dependencies
pip install -e ".[dev]"

# Install pre-commit hooks
pre-commit install
```

### **Running Tests**

The test suite includes unit tests, integration tests, and proper handling of plugin conflicts.

```bash
# Install test dependencies
pip install -e ".[dev]"

# Run all unit tests (recommended)
PYTEST_DISABLE_PLUGIN_AUTOLOAD=1 python -m pytest tests/test_config.py tests/test_config_real.py -v -p no:napari -p no:napari-plugin-engine -p no:npe2 -p no:cov

# Run specific test file
PYTEST_DISABLE_PLUGIN_AUTOLOAD=1 python -m pytest tests/test_config.py -v

# Run with coverage (unit tests only - stable)
PYTEST_DISABLE_PLUGIN_AUTOLOAD=1 python -m pytest tests/test_config.py tests/test_config_real.py --cov=notebooklm_mcp --cov-report=html

# Quick test - single unit test
PYTEST_DISABLE_PLUGIN_AUTOLOAD=1 python -m pytest tests/test_config.py::TestServerConfig::test_default_config -v
```

#### **Test Categories**

| Test Type | Status | Description | Command |
|-----------|--------|-------------|---------|
| **Unit Tests** | ✅ Stable | Config validation, core logic | `pytest tests/test_config*.py` |
| **Integration Tests** | ⚠️ Requires setup | Browser automation, full workflow | `pytest tests/test_integration.py` |
| **Client Tests** | ⚠️ Async setup needed | Client functionality | `pytest tests/test_client.py` |

#### **Test Environment Notes**

- **Napari Plugin Conflicts**: Solved with `-p no:napari` flags
- **Async Tests**: Require `pytest-asyncio` plugin configuration
- **Browser Tests**: Need actual Chrome browser installation
- **Environment Variables**: Use `PYTEST_DISABLE_PLUGIN_AUTOLOAD=1` for stability

#### **Successful Test Run Example**

```bash
$ PYTEST_DISABLE_PLUGIN_AUTOLOAD=1 python -m pytest tests/test_config.py -v
=================== test session starts ===================
collected 12 items

tests/test_config.py::TestServerConfig::test_default_config PASSED          [  8%]
tests/test_config.py::TestServerConfig::test_config_validation_success PASSED [ 16%]
tests/test_config.py::TestServerConfig::test_config_validation_negative_timeout PASSED [ 25%]
...
tests/test_config.py::TestLoadConfig::test_load_config_no_args PASSED       [100%]

=================== 12 passed in 0.30s ===================
```

#### **CI/CD & Testing Status**

Our GitHub Actions workflow ensures code quality and functionality:

| Workflow | Status | Description |
|----------|--------|-------------|
| **Unit Tests** | ✅ Stable | Config validation and core logic tests |
| **Integration Tests** | ⚡ On main branch | Browser automation and full workflow |
| **Security Scan** | 🔒 Bandit | Static security analysis |
| **Code Quality** | 📊 Multiple tools | Linting, formatting, type checking |

#### **Local Development Testing**

We use [Taskfile](https://taskfile.dev/) for streamlined task management:

```bash
# Install Taskfile (if not installed)
# macOS: brew install go-task/tap/go-task
# Linux: sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d

# Quick development test
task test:quick

# Full unit test suite (stable)
task test:unit

# Integration tests (requires Chrome)
task test:integration

# Test with coverage (≥95% required)
task test:coverage

# Development workflow
task dev:setup    # Setup environment
task dev:test     # Run tests + lint
task dev:check    # Pre-commit checks

# Show all available tasks
task --list
```

**Legacy Commands**: If you don't have Taskfile, use the direct pytest commands from the **Running Tests** section above.

## 📄 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 **Support**

- **Issues**: [GitHub Issues](https://github.com/khengyun/notebooklm-mcp/issues)
- **Discussions**: [GitHub Discussions](https://github.com/khengyun/notebooklm-mcp/discussions)

---

**⭐ If this project helps you, please give it a star!**
