# Minecraft Java Dedicated Server

Welcome to the **UNSC Minecraft** dedicated survival server! Venture into our shared survival world, build expansive bases, explore deep caves, and cooperate with fellow community members.

!!! warning "Tailscale Connection Strictly Required"
    Public port forwarding has been removed from our network gateway for security. **Tailscale is mandatory to connect to the server.**
    
    Before attempting to join, verify that Tailscale is connected on your device and that you have accepted the `unsc-gaming` machine share. See the **[Tailscale Setup Guide](tailscale.md)** for connection instructions.

---

## 📋 Server Connection Info

| Detail | Recommended Value | Direct Fallback |
| :--- | :--- | :--- |
| **Server Name** | `UNSC Minecraft` | — |
| **Server Address** | `minecraft.unscfleet.com` | `100.64.36.88` |
| **Tailscale MagicDNS** | `unsc-gaming` | — |
| **Port** | `25565` *(Default Java Port)* | `25565` |
| **Game Edition** | **Minecraft: Java Edition** (Latest) | Java Edition (Latest) |
| **World Name** | `Valley-of-Vanilla` | `Valley-of-Vanilla` |
| **Difficulty** | Normal | Normal |
| **Server MOTD** | `Powered by BinaryNexus` | `Powered by BinaryNexus` |
| **Access Gate** | **Whitelist Required** (Paid Account) | Whitelist Required |

!!! tip "Port 25565 is Automatic"
    Because our server operates on the default Minecraft Java port `25565`, you do **not** need to append `:25565` in the server address box. Simply entering `minecraft.unscfleet.com` (or `100.64.36.88`) works out of the box!

---

## 🎮 How to Join

1. **Connect to Tailscale:** Ensure Tailscale is running and connected on your device (see [Tailscale Setup](tailscale.md)).
2. Launch **Minecraft: Java Edition** (latest official release) on your PC.
3. In the Main Menu, click **Multiplayer** → **Add Server**.
4. Set **Server Name** to `UNSC Minecraft`.
5. In the **Server Address** field, enter:
   ```text
   minecraft.unscfleet.com
   ```
   *(Alternatively, enter `100.64.36.88`)*.
6. Click **Done**.
7. Select **UNSC Minecraft** from your multiplayer list (you'll see the MOTD `Powered by BinaryNexus`) and click **Join Server**!

---

## 🛡️ Whitelist & Account Verification

To protect community builds and preserve survival integrity:

1. **Official Paid Accounts Required:** The server runs in official online mode (`online-mode=true`). You must be logged into a legitimate Microsoft/Minecraft Java account.
2. **Whitelist Approval:** Send your exact in-game Minecraft Java username (case-sensitive) to **BinaryNexus** on Discord.
3. Once your username is added to the whitelist configuration, you will be able to connect right away!

---

## ⚡ Server Auto-Wake (Smart Sleep Mode)

To conserve cluster resources and hardware power, the server automatically suspends world ticks when empty for 10 minutes (`PAUSE_WHEN_EMPTY_SECONDS=600`):

- When you click **Join Server** while the server is asleep, our network gateway detects your packet and unpauses the world container.
- Your initial connection may take **5 to 15 seconds** to complete while the simulation resumes.
- Once connected, the server runs at full 20 TPS (Ticks Per Second) with zero throttling.

---

## 🚀 Recommended Launchers & Performance Mods

While the standard vanilla Minecraft launcher works seamlessly, modern client optimization mods will drastically improve your frame rates and visual fidelity:

=== "Prism Launcher (Recommended)"
    [Prism Launcher](https://prismlauncher.org/) is a clean, open-source Minecraft launcher with built-in modpack and mod management:
    1. Download and install Prism Launcher.
    2. Add your Microsoft / Minecraft account.
    3. Click **Add Instance** → select the latest Minecraft release → choose **Fabric** as the mod loader.
    4. Click **Edit Instance** → **Mods** → **Download Mods** to install the recommended performance mods listed below.

=== "Modrinth App"
    The official [Modrinth App](https://modrinth.com/app) offers 1-click modpack and shader installation. Search for the **"Fabulously Optimized"** modpack to get complete performance tweaks and shader support pre-configured out of the box!

=== "Recommended Client Mods (Fabric)"
    - **Sodium:** Replaces the Minecraft rendering engine for dramatic 3x–5x FPS boosts.
    - **Lithium:** Client-side physics and lighting optimizations.
    - **Iris Shaders:** Adds modern GPU shader pack support with near-zero overhead.
    - **FerriteCore:** Dramatically reduces Minecraft RAM usage.

---

## 🛠️ Troubleshooting & FAQ

??? question "Error: 'You are not white-listed on this server!'"
    - Your username has not yet been added to the server's approved list, or the username submitted had a typo or capitalization mismatch.
    - Double-check your exact gamer tag in the top-left of the Minecraft launcher and send it to **BinaryNexus**.

??? question "Error: 'Failed to verify username!' or 'Invalid session'"
    - Because the server runs in official online mode, your client must authenticate with Mojang/Microsoft servers.
    - Close Minecraft and your launcher completely, reopen it, and log back into your Microsoft account.

??? question "Error: 'Failed to connect: Connection refused' or 'Unknown host'"
    1. Confirm that **Tailscale** is running and toggled to **Connected** on your computer.
    2. Test connection by running `tailscale ping 100.64.36.88` in your terminal.
    3. If DNS fails to resolve `minecraft.unscfleet.com`, change your server address in Minecraft directly to:
       ```text
       100.64.36.88
       ```

??? question "Error: 'Connection timed out: getsockopt' or long join screen"
    - The server may be waking up from empty-server sleep mode. Wait 15 seconds, return to the multiplayer server list, refresh, and try connecting again.

??? question "Can I join from Minecraft Bedrock Edition (Consoles, iOS, Android, Windows Store)?"
    - Currently, our server is dedicated exclusively to **Minecraft: Java Edition**. Bedrock Edition clients cannot directly connect to vanilla Java servers without a Geyser translation layer. Please use Java Edition on PC, Mac, or Steam Deck.
