# Satisfactory Dedicated Server

Welcome to the **UNSC-Foundry (Project-MJOLNIR)** Satisfactory 1.0 dedicated server! Build massive automated factories, construct planetary logistics networks, and pioneer the frontier with friends.

!!! warning "Tailscale Connection Strictly Required"
    Public port forwarding has been removed from our network gateway for security. **Tailscale is mandatory to connect to the server.**
    
    Before attempting to join, verify that Tailscale is connected on your device and that you have accepted the `unsc-gaming` machine share. See the **[Tailscale Setup Guide](tailscale.md)** for connection instructions.

---

## 📋 Server Connection Info

| Detail | Recommended Value | Direct Fallback |
| :--- | :--- | :--- |
| **Server Name** | `UNSC-Foundry` | — |
| **Address** | `satisfactory.unscfleet.com:7777` | `100.64.36.88:7777` |
| **Ports** | `7777` (Game UDP/TCP) & `8888` (HTTPS API) | Same |
| **Platform** | Steam & Epic Games Store (Crossplay Enabled) | Crossplay Enabled |
| **Network Prerequisite** | Tailscale connected (`unsc-gaming`) | [Tailscale Guide](tailscale.md) |

---

## 🎮 How to Join

1. **Ensure Tailscale is connected** and you have accepted the `unsc-gaming` machine share (see [Tailscale Setup](tailscale.md)).
2. Launch **Satisfactory** (1.0 or newer).
3. In the Main Menu, click **Server Manager** in the left-hand navigation column.
4. Click **Add Server** in the lower-left corner.
5. In the **Address** field, enter:
   ```text
   satisfactory.unscfleet.com:7777
   ```
   *(Or enter the direct Tailscale IP: `100.64.36.88:7777`)*.
6. In the **Port** field, leave as `7777`.
7. Click **Confirm**.
8. If prompted about an untrusted or self-signed certificate, click **Accept / Confirm** (see certificate details below).
9. The server will display as online: **UNSC-Foundry**. Select it and click **Join Game**!

---

## ⚙️ Recommended In-Game Settings

Satisfactory 1.0 transfers significant factory simulation data over the network. To prevent rubberbanding and conveyor stutter, configure this essential setting:

!!! important "Set Network Quality to Ultra"
    1. In the Main Menu or pause menu, open **Options**.
    2. Navigate to the **Gameplay** tab.
    3. Locate **Network Quality** and change it from *Medium/High* to **Ultra**.
    4. Click **Apply** and save.
    
    *Setting Network Quality to Ultra increases client-server bandwidth allocation, drastically smoothing out vehicle physics, hyper tubes, and conveyor rendering on dedicated servers.*

---

## 🔐 TLS Certificate Prompt

Satisfactory 1.0 utilizes TLS encryption on port `8888` for all dedicated server management and authentication traffic. 

When you add `satisfactory.unscfleet.com` for the first time, Satisfactory displays a security notice indicating that the server certificate is self-signed:

1. Verify that the server name reads **UNSC-Foundry**.
2. Click **Accept / Confirm Certificate**.
3. You will not be prompted again on that device unless the server certificate renews.

---

## 🛠️ Troubleshooting & FAQ

??? question "Server Manager shows 'Server Offline' or fails to connect"
    1. **Tailscale Connection:** Confirm that Tailscale is connected and that running `tailscale ping 100.64.36.88` returns a pong.
    2. **Try Direct IP:** In Server Manager, delete the existing entry and re-add using `100.64.36.88:7777`.
    3. **Port Check:** Verify you included `:7777` in the address field.
    4. **System Status:** Check **[status.unscfleet.com](https://status.unscfleet.com)** to ensure the container is healthy and not restarting for a backup.

??? question "Error: 'Version Mismatch (Server: X, Client: Y)'"
    When Coffee Stain Studios releases a new game update or hotfix, your Steam/Epic client updates automatically, but the server container may need a restart to pull the new files.
    - If you see a version mismatch error, ping **BinaryNexus** on Discord so the server container can be updated.

??? question "Prompted for an Admin Password or Server Claim"
    - The server is already claimed and initialized. Players do **not** need an Admin Password to join.
    - If prompted to authenticate, simply click the regular **Join Game** button on the bottom right.

??? question "Experiencing a 2-second stutter or hitch periodically"
    - Satisfactory dedicated servers perform world auto-saves at configured intervals (e.g. every 15–30 minutes). During the world save, the game will briefly freeze for 1 to 2 seconds while the world state commits to NVMe storage. This is normal behavior for Satisfactory multiplayer.
