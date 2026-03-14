import os
from fastmcp import FastMCP
from fastmcp.server import create_proxy
from fastmcp.client.transports.stdio import StdioTransport

# Initialize the Unified Gateway
mcp = FastMCP("Unified-Gateway")

import logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

logger.info(f"Starting with FASTMCP_MESSAGE_PATH={os.getenv('FASTMCP_MESSAGE_PATH')}")

import uvicorn

# Tools will be automatically prefixed with 'home_'
mcp.mount(
    create_proxy(
        StdioTransport(
            command="github-mcp-server",
            args=["stdio"],
            env={
                **os.environ, 
                "GITHUB_PERSONAL_ACCESS_TOKEN": os.getenv("GITHUB_PERSONAL_TOKEN")
            }
        ),
        name="home"
    ),
    namespace="home"
)

# Tools will be automatically prefixed with 'work_'
mcp.mount(
    create_proxy(
        StdioTransport(
            command="github-mcp-server",
            args=["stdio"],
            env={
                **os.environ,
                "GITHUB_HOST": os.getenv("GITHUB_ENTERPRISE_URL"),
                "GITHUB_PERSONAL_ACCESS_TOKEN": os.getenv("GITHUB_ENTERPRISE_TOKEN")
            }
        ),
        name="work"
    ),
    namespace="work"
)

if __name__ == "__main__":
    # FASTMCP_MESSAGE_PATH is the internal path within the app (after gateway rewrite)
    os.environ["FASTMCP_MESSAGE_PATH"] = "/messages/"
    
    mcp.run(
        transport="sse",
        host="0.0.0.0", 
        port=8080, 
        path="/", # After gateway rewrite, app is at /
        uvicorn_config={
            "proxy_headers": True,
            "forwarded_allow_ips": "*",
            "root_path": "/mcp", # Tell library external prefix is /mcp
        }
    )
