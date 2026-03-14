import os
from fastmcp import FastMCP
from fastmcp.server import create_proxy
from fastmcp.client.transports.stdio import StdioTransport

# Initialize the Unified Gateway
mcp = FastMCP("Unified-Gateway")

# Personal GitHub Connection
# Tools will be automatically prefixed with 'home_'
mcp.mount(create_proxy(
    StdioTransport(
        command="npx",
        args=["-y", "@modelcontextprotocol/server-github"],
        env={"GITHUB_PERSONAL_TOKEN": os.getenv("GITHUB_PERSONAL_TOKEN")}
    ),
    name="home"
))

# Work GitHub Enterprise Connection
# Tools will be automatically prefixed with 'work_'
# All sensitive URLs are pulled from environment variables
mcp.mount(create_proxy(
    StdioTransport(
        command="npx",
        args=["-y", "@modelcontextprotocol/server-github"],
        env={
            "GITHUB_ENDPOINT": os.getenv("GITHUB_ENTERPRISE_URL"),
            "GITHUB_PERSONAL_TOKEN": os.getenv("GITHUB_ENTERPRISE_TOKEN")
        }
    ),
    name="work"
))

if __name__ == "__main__":
    # Run using HTTP transport for remote access compatibility
    mcp.run(transport="http", host="0.0.0.0", port=8080)
