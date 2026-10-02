# Connecting to the UNSC Gaming Network

To connect to our dedicated game servers from outside our local home network, we use **Tailscale**. Tailscale provides a secure, direct, and private connection without needing port forwarding or public exposures.

---

## 📥 1. Install Tailscale

Download and install the official Tailscale client for your device:

=== "Windows / Mac"
    1. Download from [tailscale.com/download](https://tailscale.com/download).
    2. Run the installer and sign in with your Google, Microsoft, or Apple account.

=== "Steam Deck"
    1. Switch to **Desktop Mode**.
    2. Open the **Discover Software Center** and search for **Tailscale** (or install via the official script / Decky Loader plugin).
    3. Log in with your Tailscale account and ensure the service is running.

=== "iOS / Android"
    1. Download **Tailscale** from the App Store or Google Play Store.
    2. Open the app and log in.

---

## 🤝 2. Accept the Share Invitation

1. Ask Joshua to send you an invitation to the **`unsc-gaming`** server.
2. Check your email or open the share link directly.
3. Click **Accept Share** while logged into your Tailscale account.

> [!NOTE]
> Once accepted, you will see **`unsc-gaming`** (`100.64.36.88`) appear in your Tailscale device list. You do **not** need to accept separate shares for Satisfactory, Palworld, or Minecraft—they all live on this single machine!

---

## 🔍 3. Verify Your Connection

To verify that your computer can reach the gaming server, open your terminal (Command Prompt / PowerShell on Windows, or Konsole on Linux/Steam Deck) and run:

```bash
tailscale ping 100.64.36.88
```

You should see:
```text
pong from unsc-gaming (100.64.36.88) via ... in XX ms
```

Once you see a `pong`, you are ready to join any of our game servers!
