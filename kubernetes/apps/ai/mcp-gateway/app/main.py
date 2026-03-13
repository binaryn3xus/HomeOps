import os
from fastmcp import FastMCP
from fastmcp.server import create_proxy

# Initialize the Unified Gateway
mcp = FastMCP("Unified-Gateway")

# Personal GitHub Connection
# Tools will be automatically prefixed with 'home_'
mcp.mount(create_proxy(
    "npx -y @modelcontextprotocol/server-github",
    name="home",
    env={"GITHUB_PERSONAL_TOKEN": os.getenv("GITHUB_PERSONAL_TOKEN")}
))

# Work GitHub Enterprise Connection
# Tools will be automatically prefixed with 'work_'
# All sensitive URLs are pulled from environment variables
mcp.mount(create_proxy(
    "npx -y @modelcontextprotocol/server-github",
    name="work",
    env={
        "GITHUB_ENDPOINT": os.getenv("GITHUB_ENTERPRISE_URL"),
        "GITHUB_PERSONAL_TOKEN": os.getenv("GITHUB_ENTERPRISE_TOKEN")
    }
))

if __name__ == "__main__":
    # Run using HTTP transport for remote access compatibility
    mcp.run(transport="http", host="0.0.0.0", port=8080)
