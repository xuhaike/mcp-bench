# MCP-Bench Setup Guide

This guide will help you set up the MCP-Bench environment from scratch.

## Prerequisites

- **Python**: 3.10 or higher (3.12+ recommended)
- **Node.js**: 18 or higher (for TypeScript MCP servers)
- **Git**: For cloning the repository
- **Operating System**: Linux, macOS, or Windows with WSL

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/mcp-bench.git
cd mcp-bench
```

### 2. Set Up Python Environment

#### Option A: Using Conda (Recommended)

```bash
# Create conda environment
conda create -n mcpbench python=3.10 -y
conda activate mcpbench

# Install dependencies
pip install -r requirements.txt
```

#### Option B: Using venv

```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

### 3. Install Node.js Dependencies and MCP Servers

```bash
cd mcp_servers
sudo ./install.sh
```

**Note**: The install script will:
- Install Node.js package managers (pnpm, yarn, tsx)
- Install uv (modern Python package manager)
- Build all TypeScript MCP servers
- Install Python MCP server dependencies

If you encounter permission errors, the script uses `sudo` for global npm packages and system-wide installations.

### 4. Configure API Keys

Edit the API key configuration file:

```bash
nano mcp_servers/api_key
```

Replace `YOUR_KEY_HERE` with your actual API keys:

```bash
NPS_API_KEY=your_national_parks_api_key
NASA_API_KEY=your_nasa_api_key
HF_TOKEN=your_huggingface_token
GOOGLE_MAPS_API_KEY=your_google_maps_api_key
NCI_API_KEY=your_nci_api_key
```

**Where to get API keys:**
- National Parks: https://www.nps.gov/subjects/developer/
- NASA: https://api.nasa.gov/
- Hugging Face: https://huggingface.co/settings/tokens
- Google Maps: https://console.cloud.google.com/apis/credentials

### 5. Configure LLM Provider

Edit the environment file:

```bash
nano mcp_servers/.env
```

Add your LLM provider API key:

```bash
export OPENROUTER_API_KEY="your-openrouter-api-key"
# Or use OpenAI directly
export OPENAI_API_KEY="your-openai-api-key"
```

### 6. Source Environment Variables

```bash
source mcp_servers/.env
source mcp_servers/api_key
```

## Verification

### Test MCP Server Collection

```bash
conda activate mcpbench  # if using conda
python ./utils/collect_mcp_info.py
```

This should connect to all 28 MCP servers and collect tool information.

### Run Benchmark

```bash
python benchmark/runner.py
```

## Troubleshooting

### Permission Errors During Installation

If you get permission errors when running `install.sh`:

1. **For npm global packages**: The script uses `sudo` by default
2. **For Python packages**: Make sure you're in your conda/venv environment
3. **For file permissions**: Run `sudo chown -R $USER:$USER mcp_servers`

### Module Not Found Errors

If you get `ModuleNotFoundError`:

```bash
# Reinstall specific packages in your environment
conda activate mcpbench  # or activate your venv
pip install -e mcp_servers/unit-converter-mcp
pip install -e mcp_servers/time-mcp
```

### Virtual Environment Conflicts

If `.venv` directories have permission issues:

```bash
# Remove problematic .venv directories
sudo rm -rf mcp_servers/*/.venv

# They will be recreated as needed
```

### Missing uv Command

If `uv` is not found after installation:

```bash
# Add uv to PATH
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

# Make it permanent
echo 'export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

## Environment File Structure

```
mcp-bench/
├── requirements.txt          # Main Python dependencies
├── mcp_servers/
│   ├── install.sh           # Installation script for MCP servers
│   ├── requirements.txt     # MCP server dependencies
│   ├── .env                 # LLM API keys
│   └── api_key              # MCP server API keys
├── benchmark/               # Benchmark code
├── utils/                   # Utility scripts
└── mcp_modules/            # MCP management modules
```

## Common Issues

### 1. Ubuntu PEP 668 Protection

On Ubuntu 24.04+, you may see:
```
error: externally-managed-environment
```

**Solution**: The install.sh script now uses `--break-system-packages` flag automatically.

### 2. Conda vs System Python

Make sure you're using the correct Python:

```bash
which python  # Should point to your conda/venv Python
python --version  # Should be 3.10+
```

### 3. Node.js Version

Check Node.js version:

```bash
node --version  # Should be v18+
npm --version   # Should be 9+
```

If outdated, update Node.js:

```bash
# Using nvm (recommended)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install 20
nvm use 20
```

## Clean Installation

To start fresh:

```bash
# Remove conda environment
conda deactivate
conda env remove -n mcpbench

# Remove node_modules and build artifacts
cd mcp_servers
find . -name "node_modules" -type d -exec rm -rf {} +
find . -name "dist" -type d -exec rm -rf {} +
find . -name "build" -type d -exec rm -rf {} +

# Start from step 2 in Quick Start
```

## Getting Help

If you encounter issues:

1. Check this guide's troubleshooting section
2. Review server logs in `mcp_servers/`
3. Check individual server README files
4. Open an issue on GitHub with:
   - Your OS and version
   - Python version
   - Node.js version
   - Full error message
   - Steps to reproduce

## Next Steps

After successful setup:

1. Review `README.md` for usage instructions
2. Explore available MCP servers in `mcp_servers/`
3. Check out example benchmarks in `benchmark/`
4. Read `mcp_servers_info.md` for server documentation
