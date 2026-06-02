# Hermes Redesign

This directory contains the configuration for the Hermes Agent.

## Recent Changes (2026-05-31)

To address friction in the workflow and improve autonomy:

1.  **Auto-Orchestration**: Enabled `kanban.auto_decompose`. Hermes will now automatically break down complex tasks in the **Triage** column without manual intervention.
2.  **Maximum Autonomy (YOLO Mode)**: Changed `approvals.mode` from `smart` to `yolo`. This eliminates manual confirmation for all commands, allowing agents to work at full speed.
3.  **Command Allowlist**: Pre-populated `command_allowlist` with standard development tools (`git`, `npm`, `python`, etc.) to ensure baseline operations are never gated.
4.  **Consent Gates & Allowlists**: Configured `consents.outbound_access` to `smart` mode and added an `allowlist` for internal and trusted external endpoints.
    -   **UniFi Controller**: `10.0.10.1` is now pre-approved for configuration audits.
    -   **Internal Cluster**: `*.svc.cluster.local` and `*.unscfleet.com` are trusted for service-to-service communication.
    -   **GitHub API**: Pre-approved for development and audit tasks.
4.  **Sidecar Architecture**: Split the deployment into two distinct containers:
    -   **gateway**: The "Primary" container. It runs a **Self-Healing Watchdog Loop** that ensures all background gateways (default + specialized profiles) are kept alive. It also hosts Kubernetes `livenessProbe` and `readinessProbe` to verify connection health.
    -   **dashboard**: The "Interface" container. Setting `S6_PROFILE_GATEWAY_SCANDIR=/tmp/ignored-services` prevents this container from attempting to start background gateways or lock log files.
5.  **Robust Health Monitoring**: Added native Kubernetes probes that run `hermes gateway status`. This ensures the pod is only considered "Healthy/Ready" if at least one messaging gateway is successfully connected.
6.  **Scalable Profile Sync (Symlinks)**: Re-introduced a lightweight `initContainer` to solve the "Profile Island" problem.
    -   **Master Link**: Instead of copying, it creates symbolic links from `/opt/data/profiles/*/config.yaml` back to the master `/opt/data/config.yaml`.
    -   **Automatic Scaling**: The `find` command automatically discovers and links any new profiles created in the future, ensuring they all inherit the same security allowlists and auto-orchestration rules.
6.  **Permission Management**: Used `fsGroup: 10000` and a targeted `chown` in the initContainer to ensure the PVC remains writable by the `hermes` user across all pods.
6.  **Expanded Capabilities**: Explicitly enabled all toolsets (`toolsets: [all]`) to ensure the agent has full access to terminal, file, and web tools.
7.  **Responsive Dispatching**: Reduced the `dispatch_interval_seconds` to 30 seconds for faster task transitions.


## Maintaining the "SOUL"

- **Personality**: The `display.personality: "kawaii"` setting is preserved.
- **Tools**: Hermes remains integrated with Home Assistant, GitHub, Paperless, and more via `externalsecret.yaml`.
- **Identity**: The agent's identity as "Skippy" (Discord) is maintained via secrets.

## Future Improvements

- **Profiles**: Consider moving agent profiles from the PVC to GitOps to ensure system prompts and specialized personas are version-controlled.
- **Model Tuning**: If `gpt-5.3-codex` latency is high, consider using `auxiliary` models for specific tasks like summarization or decomposition.
