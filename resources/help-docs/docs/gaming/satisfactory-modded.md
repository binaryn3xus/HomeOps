# Satisfactory Modded Dedicated Server

Welcome to the **UNSC-Section-III** Satisfactory dedicated server! This instance runs alongside our vanilla server, featuring quality-of-life enhancements, building improvements, and gameplay tweaks powered by the **Satisfactory Mod Loader (SML)**.

!!! warning "Tailscale Connection Strictly Required"
    Public port forwarding has been removed from our network gateway for security. **Tailscale is mandatory to connect to the server.**
    
    Before attempting to join, verify that Tailscale is connected on your device and that you have accepted the `unsc-gaming` machine share. See the **[Tailscale Setup Guide](tailscale.md)** for connection instructions.

!!! info "Looking for our Vanilla Server?"
    If you are looking for our pure vanilla 1.0 server without any mods, see the **[UNSC-Foundry Guide](satisfactory.md)**.

---

## 📋 Server Connection Info

| Detail | Recommended Value | Direct Fallback |
| :--- | :--- | :--- |
| **Server Name** | `UNSC-Section-III` | — |
| **Address** | `satisfactory-modded.unscfleet.com:7778` | `100.64.36.88:7778` |
| **Ports** | `7778` (Game UDP/TCP & HTTPS API) & `8889` (Reliable Messaging TCP) | Same |
| **Platform** | Steam & Epic Games Store (Crossplay Enabled) | Crossplay Enabled |
| **Network Prerequisite** | Tailscale connected (`unsc-gaming`) | [Tailscale Guide](tailscale.md) |
| **Save Downloader & Map** | [satisfactory-modded-saves.unscfleet.com](https://satisfactory-modded-saves.unscfleet.com) | Direct Web Portal |

---

## 🧩 Mod Setup (Satisfactory Mod Manager)

Because this server runs custom mods, **your client must have the matching mods installed** before joining.

### 1. Download Satisfactory Mod Manager (SMM)
1. Download and install **Satisfactory Mod Manager** from the official Ficsit community site:
   [:material-download: Download Satisfactory Mod Manager (ficsit.app)](https://ficsit.app){ .md-button .md-button--primary target="_blank" }
2. Launch SMM. It will automatically detect your Steam or Epic Games installation of Satisfactory.

### 2. Install Required Server Mods
Ensure the following mods are installed and toggled **ON** in SMM:

| Mod Name | Description | SMM Link |
| :--- | :--- | :--- |
| **SML** | Satisfactory Mod Loader (Core dependency) | Included automatically |
| **Daisy Chain Power Cables** | Connect power cables directly between machines and poles | [View on Ficsit](https://ficsit.app/mod/DaisyChainPowerCables) |
| **Faster Manual Crafting Redux** | Speeds up hold-to-craft workbench progression | [View on Ficsit](https://ficsit.app/mod/FasterManualCraftingRedux) |
| **BoomBoxPlus** | Custom and expanded boombox audio playback | [View on Ficsit](https://ficsit.app/mod/BoomBoxPlus) |
| **Ficsit Remote Monitoring** | Telemetry and factory stats monitoring API | [View on Ficsit](https://ficsit.app/mod/FicsitRemoteMonitoring) |
| **PEP Mod (Persistent Enhanced Power)** | Enhanced power management and distribution tools | [View on Ficsit](https://ficsit.app/mod/PEP_Mod) |
| **Mod Update Notifier** | Alerts when mods need updates | [View on Ficsit](https://ficsit.app/mod/ModUpdateNotifier) |

!!! tip "One-Click Profile Import"
    In SMM, you can create a dedicated profile named `UNSC-Section-III` so you can switch easily between vanilla Satisfactory and modded Satisfactory with a single click!

---

## 🎮 How to Join

1. **Connect to Tailscale:** Verify that Tailscale is connected and that you have accepted the `unsc-gaming` share (see [Tailscale Setup](tailscale.md)).
2. **Launch Satisfactory:** In Satisfactory Mod Manager (SMM), click **Launch Game** (with the `Mods: ON` switch selected).
3. **Open Server Manager:** In the Satisfactory Main Menu, click **Server Manager** on the left.
4. **Add Server:** Click **Add Server** in the lower-left corner.
5. In the **Address** field, enter:
   ```text
   satisfactory-modded.unscfleet.com:7778
   ```
   *(Or enter the direct Tailscale IP: `100.64.36.88:7778`)*.
6. In the **Port** field, enter `7778`.
7. Click **Confirm**.
8. The server will display as online: **UNSC-Section-III**. Select it and click **Join Game**!

---

## 🗺️ Save Backups & Interactive Map

We host an automated save download portal and interactive factory map for `UNSC-Section-III`:

[:material-map-legend: UNSC-Section-III Save Downloader & SCIM Map](https://satisfactory-modded-saves.unscfleet.com){ .md-button .md-button--primary target="_blank" }

* **Download Latest Save:** Grab the most recent world autosave directly to your computer.
* **Interactive Map (SCIM):** Click the **"Open Latest in SCIM"** button to view power grids, train lines, conveyor throughput, and hard drive locations in your browser on Satisfactory-Calculator.
* **Automated Off-site Backups:** World saves and player settings are continuously backed up off-site every hour.

---

## ⚙️ Recommended In-Game Settings

Satisfactory transfers substantial simulation data over the network. Configure this setting to prevent stuttering and sync issues:

!!! important "Set Network Quality to Ultra"
    1. In the Main Menu or pause menu, open **Options**.
    2. Navigate to the **Gameplay** tab.
    3. Locate **Network Quality** and change it from *Medium/High* to **Ultra**.
    4. Click **Apply** and save.

---

## 🛠️ Troubleshooting & FAQ

??? question "Error: 'Server Missing Mods' or 'Client Missing Mods'"
    - This error occurs when your local client mods do not match the mods running on the server.
    - Open **Satisfactory Mod Manager**, check the mod list above, and verify all mods are updated to their latest versions.
    - Make sure you clicked **Launch Game** from SMM so the mods are mounted into Unreal Engine at launch.

??? question "Server Manager shows 'Server Offline' or connection times out"
    1. **Tailscale Connection:** Confirm that Tailscale is connected. Open PowerShell and run:
       ```powershell
       Test-NetConnection satisfactory-modded.unscfleet.com -Port 7778
       ```
       If it fails, disconnect and reconnect Tailscale in your system tray to refresh your session keys.
    2. **Try Direct Tailscale IP:** In Server Manager, add the server using `100.64.36.88:7778`.
    3. **Verify Port:** Make sure you specified port `7778` (the vanilla server is on `7777`, while this modded server is on `7778`).
    4. **System Status:** Check **[status.unscfleet.com](https://status.unscfleet.com)** to verify the server container is healthy.

??? question "Error: 'Version Mismatch (Server: X, Client: Y)'"
    When Satisfactory receives a game patch, the server container may need a restart to download the update from SteamCMD.
    - If you see a version mismatch error, ping **BinaryNexus** on Discord so the container can be restarted.
