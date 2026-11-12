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
| **Save & Mod Portal** | [satisfactory-modded-saves.unscfleet.com](https://satisfactory-modded-saves.unscfleet.com) | Live `.smmprofile`, Mod List & Saves |
| **SMM Profile Download** | [UNSC-Section-III.smmprofile](https://satisfactory-modded-saves.unscfleet.com/UNSC-Section-III.smmprofile) | One-Click SMM Import |

---

## 🧩 Mod Setup (Satisfactory Mod Manager)

Because this server runs custom mods, **your client must have the exact matching mods installed** before joining. Our server automatically exports a live **Satisfactory Mod Manager (SMM)** profile directly from the running server filesystem so you never have to install or update mods one-by-one.

### 1. Download Satisfactory Mod Manager (SMM)
1. Download and install **Satisfactory Mod Manager** from the official Ficsit community site:
   [:material-download: Download Satisfactory Mod Manager (ficsit.app)](https://ficsit.app){ .md-button .md-button--primary target="_blank" }
2. Launch SMM. It will automatically detect your Steam or Epic Games installation of Satisfactory.

### 2. Import the Live Server Profile (Recommended)
Instead of searching for mods manually, download and import our live server profile:

[:material-file-download: Download UNSC-Section-III.smmprofile (Live Server Export)](https://satisfactory-modded-saves.unscfleet.com/UNSC-Section-III.smmprofile){ .md-button .md-button--primary }

1. Click the button above to download **`UNSC-Section-III.smmprofile`** *(requires Tailscale connected)*.
2. In **Satisfactory Mod Manager**, locate the **Profile** dropdown at the top-left of the window and click the **Import Profile** icon (or go to **Profiles → Import Profile**).
3. Select the downloaded `UNSC-Section-III.smmprofile` file and name the profile **`UNSC-Section-III`**.
4. Make sure the **`Mods: ON`** toggle is enabled in SMM. SMM will automatically download and lock the exact mod versions currently running on the server!

!!! tip "Switching Between Vanilla and Modded"
    Using a dedicated `UNSC-Section-III` profile in SMM lets you switch between modded (`UNSC-Section-III`) and vanilla (`UNSC-Foundry`) with a single click—or simply toggle `Mods: OFF` when joining the vanilla server.

### 3. Live Installed Server Mods
The table below automatically fetches the currently installed mods and versions directly from the running server:

<div class="md-typeset__scrollwrap">
  <div class="md-typeset__table">
    <table>
      <thead>
        <tr>
          <th>Mod Name</th>
          <th>Version</th>
          <th>Description</th>
          <th>SMM Link</th>
        </tr>
      </thead>
      <tbody id="unsc-live-mods-tbody">
        <tr>
          <td colspan="4"><em>Loading live mod list from server...</em></td>
        </tr>
      </tbody>
    </table>
  </div>
</div>

<script>
(function() {
  function escapeHtml(str) {
    return String(str || "")
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;");
  }

  function loadUnscServerMods() {
    var tbody = document.getElementById("unsc-live-mods-tbody");
    if (!tbody || tbody.dataset.loaded === "true") return;

    fetch("https://satisfactory-modded-saves.unscfleet.com/mods.json", { cache: "no-store" })
      .then(function(res) {
        if (!res.ok) throw new Error("HTTP " + res.status);
        return res.json();
      })
      .then(function(data) {
        var mods = (data && data.mods) || [];
        if (!mods.length) throw new Error("No mods returned");
        tbody.dataset.loaded = "true";
        tbody.innerHTML = mods.map(function(m) {
          var name = "<strong>" + escapeHtml(m.name || m.ref) + "</strong>";
          var ver = "<code>v" + escapeHtml(m.version || "latest") + "</code>";
          var desc = escapeHtml(m.description || "Required server mod");
          var link = m.is_sml
            ? "Included automatically"
            : '<a href="' + escapeHtml(m.ficsit_url) + '" target="_blank" rel="noopener noreferrer">View on Ficsit</a>';
          return "<tr><td>" + name + "</td><td>" + ver + "</td><td>" + desc + "</td><td>" + link + "</td></tr>";
        }).join("");
      })
      .catch(function() {
        tbody.innerHTML = '<tr><td colspan="4">Unable to reach live mod API. View the active mod list directly on <a href="https://satisfactory-modded-saves.unscfleet.com" target="_blank" rel="noopener noreferrer">satisfactory-modded-saves.unscfleet.com</a>.</td></tr>';
      });
  }

  loadUnscServerMods();
  if (typeof document$ !== "undefined" && !window.__unscModsSubscribed) {
    window.__unscModsSubscribed = true;
    document$.subscribe(loadUnscServerMods);
  }
})();
</script>

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
    - This error occurs when your local client mods or versions do not match what is currently running on the server.
    - **Quick Fix:** Download the latest **[UNSC-Section-III.smmprofile](https://satisfactory-modded-saves.unscfleet.com/UNSC-Section-III.smmprofile)** and re-import it in **Satisfactory Mod Manager** (*Profiles → Import Profile*), or check the live version list at **[satisfactory-modded-saves.unscfleet.com](https://satisfactory-modded-saves.unscfleet.com)**.
    - Make sure `Mods: ON` is enabled in SMM before launching the game.

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
