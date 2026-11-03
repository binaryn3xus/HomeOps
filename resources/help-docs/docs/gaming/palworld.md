# Palworld Dedicated Server

Welcome to the **UNSC-Palworld** dedicated server! Explore the Palpagos Islands, capture and train Pals, build automated assembly bases, and take down syndicate tower bosses with the community.

!!! warning "Tailscale Connection Strictly Required"
    Public port forwarding has been removed from our network gateway for security. **Tailscale is mandatory to connect to the server.**
    
    Before attempting to join, verify that Tailscale is connected on your device and that you have accepted the `unsc-gaming` machine share. See the **[Tailscale Setup Guide](tailscale.md)** for connection instructions.

---

## 📋 Server Connection Info

| Detail | Recommended Value | Direct Fallback |
| :--- | :--- | :--- |
| **Server Name** | `UNSC-Palworld` | — |
| **Direct Address** | `palworld.unscfleet.com:8211` | `100.64.36.88:8211` |
| **Port** | `8211` (UDP) | `8211` (UDP) |
| **Platform** | Steam (PC) | Steam (PC) |
| **Web Dashboard** | [palworld-dashboard.unscfleet.com](https://palworld-dashboard.unscfleet.com) | Live Stats & Online Players |
| **Network Prerequisite** | Tailscale connected (`unsc-gaming`) | [Tailscale Guide](tailscale.md) |

---

## 🎮 How to Join

1. **Connect to Tailscale:** Confirm Tailscale is active and running on your PC (see [Tailscale Setup](tailscale.md)).
2. Launch **Palworld** on Steam.
3. In the Main Menu, click **Join Multiplayer Game**.
4. **Ignore the public server browser list.** Instead, scroll to the **very bottom of the screen** to find the **Direct Connect input box**.
5. Type or paste the following connection string into the box:
   ```text
   palworld.unscfleet.com:8211
   ```
   *(Or enter the direct Tailscale IP: `100.64.36.88:8211`)*.
6. Click **Connect**!

!!! tip "Remembering the Address"
    Palworld automatically saves the last direct connect address you used. For future sessions, simply click **Join Multiplayer Game** and click **Connect** right away!

---

## 📊 Live Web Dashboard

We host a live server dashboard displaying real-time metrics, server health, and online player rosters:

[Open Palworld Dashboard :material-open-in-new:](https://palworld-dashboard.unscfleet.com){ .md-button .md-button--primary target="_blank" }

### Dashboard Features
- **Active Players:** See who is currently online, their player levels, and ping times.
- **Server Health:** View RAM consumption, tick rates, and container uptime.
- **World Statistics:** Inspect total captured Pals, active guilds, and base distribution across the map.

---

## 🛠️ Troubleshooting & FAQ

??? question "Error: 'Failed to connect to the server' / 'Connection timed out'"
    1. **Check Tailscale:** Verify Tailscale is running and connected. Run `tailscale ping 100.64.36.88` to verify network reachability.
    2. **Check Port Number:** Ensure you typed `:8211` at the end of the address. The default box sometimes clears the port.
    3. **Try Direct IP:** Enter `100.64.36.88:8211` directly into the input box instead of the domain name.
    4. **Server Rebooting:** Palworld dedicated servers undergo periodic memory maintenance. Check **[palworld-dashboard.unscfleet.com](https://palworld-dashboard.unscfleet.com)** or **[status.unscfleet.com](https://status.unscfleet.com)** to check if the server is in the middle of a restart.

??? question "Black screen or infinite loading upon connecting"
    1. **Restart Palworld:** Close Palworld completely from Steam and relaunch.
    2. **Verify Steam Game Files:** Right-click Palworld in your Steam Library → **Properties** → **Installed Files** → **Verify integrity of game files**.
    3. **DirectX / Unreal Engine Crash:** If the game crashes on joining, try launching Palworld with DirectX 11 by adding `-dx11` or `-force-d3d11` to the game's Steam Launch Options.

??? question "Version mismatch error after a Steam update"
    Pocketpair regularly releases hotfixes and balance patches for Palworld. When your local Steam client updates to a new version, the dedicated server must also be updated.
    - If you get a version mismatch warning, ping an **Admin** to trigger the server update script.
