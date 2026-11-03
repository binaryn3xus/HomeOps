# Connecting to the UNSC Gaming Network

To connect to our dedicated game servers, we use **Tailscale**. Tailscale creates a secure, encrypted peer-to-peer connection directly between your device and our gaming server without needing open ports on the public internet.

---

## 📥 1. Install Tailscale

Download and install the official Tailscale client for your gaming device:

=== "Windows / Mac"
    1. Download the installer from [tailscale.com/download](https://tailscale.com/download).
    2. Run the installer and sign in with your Google, Microsoft, or Apple account.
    3. Ensure Tailscale is running in your system tray (Windows) or menu bar (macOS) and shows **Connected**.

=== "Steam Deck"
    1. Switch your Steam Deck to **Desktop Mode** (Steam Button → Power → Switch to Desktop).
    2. Open the **Discover Software Center** and search for **Tailscale**, or install via the terminal / Decky Loader plugin (**Tailscale for Decky**).
    3. Launch Tailscale, log in with your account, and toggle connection to **On**.
    4. *(Optional)* Return to Gaming Mode. If you installed the Decky Loader plugin, you can toggle Tailscale directly from the Quick Access menu inside games.

=== "Linux"
    Install using the official one-line script:
    ```bash
    curl -fsSL https://tailscale.com/install.sh | sh
    sudo tailscale up
    ```

=== "iOS / Android"
    1. Download **Tailscale** from the [Apple App Store](https://apps.apple.com/us/app/tailscale/id1470499037) or [Google Play Store](https://play.google.com/store/apps/details?id=com.tailscale.ipn).
    2. Open the app, grant VPN permissions, and log in.
    3. Toggle the switch to **Active**.

!!! tip "First-Time Users: Skip the Setup Wizard!"
    When you create a brand-new Tailscale account, the web dashboard or app may present an onboarding checklist asking you to *"Add your first machine"*, *"Configure a subnet router"*, or *"Set up your tailnet"*.
    
    **You can completely skip or ignore this!** You are connecting as an invited guest to our gaming server—you do not need to create or configure a server of your own. Simply log in, then proceed to Step 2 below.

---

## 🤝 2. Accept the Share Invitation

Our games all run behind a single dedicated gateway node: **`unsc-gaming`**.

1. Ask an **Admin** to send you a Tailscale share invitation to **`unsc-gaming`**.
2. Check your email or open the share link directly in your browser.
3. Click **Accept Share** while logged into the same Tailscale account you use on your device.

!!! success "One Share Unlocks All Games"
    Once accepted, **`unsc-gaming`** (`100.64.36.88`) will appear in your device list under **Shared with you**. You do **not** need separate shares for Satisfactory, Palworld, or Minecraft—they all route through this single machine!

---

## 🔍 3. Verify Your Connection

To confirm your device can reach the server, open your terminal (PowerShell / Command Prompt on Windows, Terminal on Mac, or Konsole on Linux/Steam Deck) and run:

```bash
tailscale ping 100.64.36.88
```

You should see an immediate response:

```text
pong from unsc-gaming (100.64.36.88) via ... in XX ms
```

Alternatively, you can test a standard network ping:

```bash
ping 100.64.36.88
```

Once you receive replies, you are connected and ready to jump into any game!

---

## 🛠️ Troubleshooting & FAQ

??? question "Ping times out or says 'Request timed out' / 'Destination Host Unreachable'"
    1. **Check Tailscale Status:** Open your Tailscale client app and confirm the status says **Connected** (the tray icon should not be grayed out).
    2. **Verify Invitation Accepted:** Visit [login.tailscale.com/admin/machines](https://login.tailscale.com/admin/machines) and verify that **`unsc-gaming`** appears under the "Shared" section.
    3. **Disable Conflicting VPNs:** Commercial VPNs (such as NordVPN, ExpressVPN, Surfshark, or corporate VPNs) often take exclusive control of system routing. Turn them off while gaming.
    4. **Expired Key:** If it's been several months since you last played, your Tailscale session key may have expired. Open Tailscale, log out, and log back in.

??? question "Steam Deck disconnects after sleep / suspend"
    When the Steam Deck enters sleep mode, network interfaces power down and Tailscale temporarily suspends. When waking the deck:
    - Give the Deck 5–10 seconds to restore its internet connection.
    - If a game fails to reconnect, switch to Desktop Mode or use the **Decky Loader Tailscale** widget to toggle the connection off and back on.

??? question "Windows Firewall or 'Public Network' prompt"
    When Windows detects a new virtual network adapter, it may categorize Tailscale as a "Public Network" and block inbound game traffic:
    - If prompted by Windows Defender Firewall, check **Allow on Private and Public networks**.
    - In Windows Settings → Network & Internet → Tailscale, ensure network profile type is set to **Private**.

??? question "Can I use the hostname or do I need the IP?"
    Both work!
    - **MagicDNS Hostname:** `unsc-gaming`
    - **Fully Qualified Domain:** `satisfactory.unscfleet.com`, `palworld.unscfleet.com`, `minecraft.unscfleet.com`
    - **Direct Tailscale IP:** `100.64.36.88`
    
    If your computer has custom DNS servers that prevent domain name resolution over Tailscale, you can always enter the Direct Tailscale IP (`100.64.36.88`) directly in your game client.
