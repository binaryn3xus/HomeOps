# 🎬 Video Streaming

UNSC Fleet hosts high-definition movie and television libraries featuring 4K HDR/Dolby Vision video, multi-channel surround sound, automatic subtitle matching, and multi-device progress syncing. You can stream using **Plex** or **Jellyfin**.

---

## 📺 Streaming Platforms

=== "Plex (Recommended for Most Devices)"

    **Plex** offers a polished interface available natively on virtually every smart TV, streaming stick, game console, and mobile device.

    ### 🌐 Web Access
    Stream directly in your web browser:

    [Launch Plex Web :material-open-in-new:](https://plex.unscfleet.com){ .md-button .md-button--primary target="_blank" }
    [Hosted App (plex.tv)](https://app.plex.tv){ .md-button target="_blank" }

    ### 📱 Download Apps
    [Apple App Store :material-apple:](https://apps.apple.com/us/app/plex-find-movies-and-tv-shows/id383457673){ .md-button target="_blank" }
    [Google Play Store :material-google-play:](https://play.google.com/store/apps/details?id=com.plexapp.android){ .md-button target="_blank" }

    #### 📺 Smart TVs & Streaming Devices
    Search for **Plex** in your device's built-in app store:
    - **Apple TV / Roku / Fire TV / Google TV / Android TV**
    - **Samsung Smart TVs (Tizen)** & **LG Smart TVs (webOS)**
    - **PlayStation 5 & Xbox Series X/S**

    ### 🔑 Getting Access
    1. Create a free account at [plex.tv](https://www.plex.tv/) if you don't already have one.
    2. Send your Plex username or email address to an **Admin**.
    3. Accept the server library invitation received via email or in the Plex app under your user avatar.

    ### 🚀 Crucial Setup: Maximize Video Quality
    
    !!! danger "The Default 720p Trap in Plex"
        By default, freshly installed Plex apps limit remote streaming to **2 Mbps (720p)** or enable "Automatically Adjust Quality".
        
        This forces our server to downsample stunning 4K and 1080p media into blurry 720p video, washing out colors and causing unnecessary buffering!
        
        **Follow these steps on your device to enjoy pristine Direct Play quality:**

    ??? tip "Apple TV & iOS Setup"
        1. Open the Plex app → tap your profile icon → open **Settings** (gear icon).
        2. Select **Quality** or **Video Quality**.
        3. Set **Remote Streaming** / **Internet Streaming** to **Maximum** or **Original**.
        4. Set **Auto Adjust Quality** to **Off**.
        5. Under **Audio & Subtitles**, set **Burn Subtitles** to **Automatic** or **Only Image Formats**.

    ??? tip "Roku Setup"
        1. Open Plex → click your user profile / initials → **Settings**.
        2. Navigate to **Video**.
        3. Change **Local Quality** and **Remote Quality** to **Original**.
        4. Turn **Direct Play** to **On** or **Auto**.

    ??? tip "Google TV / Android TV / Fire TV Setup"
        1. Open Plex → select your profile avatar → **Settings**.
        2. Go to **Video Quality**.
        3. Set **Adjust Automatically** to **Off**.
        4. Set **Remote Streaming Quality** to **Maximum** / **Original**.
        5. Set **Audio Boost** to **None** or your preferred level.

    ??? tip "Web Browser Setup"
        1. Open [plex.unscfleet.com](https://plex.unscfleet.com) or [app.plex.tv](https://app.plex.tv).
        2. Click the **Settings (wrench icon)** in the top right header.
        3. Under the **Plex Web** section on the left sidebar, click **Quality**.
        4. Set **Video Quality** to **Maximum**.
        5. Uncheck **Automatically adjust quality**.

=== "Jellyfin (Privacy-Focused Open Source)"

    **Jellyfin** is our 100% free, privacy-focused open-source media platform with no third-party tracking or cloud dependencies.

    !!! important "Account Setup Required"
        Jellyfin accounts cannot be self-registered and must be created manually by an Admin.
        
        Send a message to the **Admin** to have your username and password set up before attempting to sign in.

    ### 🌐 Web Access
    Stream directly from any browser:

    [Launch Jellyfin Web :material-open-in-new:](https://jellyfin.unscfleet.com){ .md-button .md-button--primary target="_blank" }

    ### 📱 Recommended Client Apps
    [Swiftfin for Apple TV & iOS :material-apple:](https://apps.apple.com/us/app/swiftfin/id1604098728){ .md-button target="_blank" }
    [Jellyfin for Android :material-google-play:](https://play.google.com/store/apps/details?id=org.jellyfin.mobile){ .md-button target="_blank" }

    #### 📺 Smart TVs & Streaming Devices
    - **Apple TV:** Install **Swiftfin** from the tvOS App Store.
    - **Google TV / Android TV / Fire TV:** Search for **Jellyfin** in the Google Play Store or Amazon App Store.
    - **Roku:** Install the official **Jellyfin** channel from the Roku Channel Store.

    ### 🔑 Setup Instructions
    1. Open the Jellyfin or Swiftfin app.
    2. When prompted for **Server Address**, enter:
       ```text
       https://jellyfin.unscfleet.com
       ```
    3. Enter the username and password provided to you by an **Admin**.

    ### ⚙️ Recommended Playback Settings
    - In **Swiftfin** or the **Jellyfin** client app, open **Settings** → **Playback**.
    - Set **Max Bitrate** to **Auto** or your highest available connection speed.
    - Set **Preferred Video Player** to **Native** (iOS/Apple TV) or **ExoPlayer** (Android) for smooth hardware-accelerated playback.

---

## 🎧 Subtitles & Multi-Audio Tracks

Our media library includes multi-language subtitles and alternate audio streams:

- **Switching Audio:** While playing any movie or episode, open the playback settings menu (slider icon) to choose between 5.1/7.1 Surround Sound, Stereo (ideal for mobile/laptops), or Director Commentaries.
- **Subtitles:** Both Plex and Jellyfin allow on-the-fly subtitle toggling. If subtitles are out of sync, use the in-player **Subtitle Offset** tool to shift timing forward or backward by milliseconds.
- **Search for Subtitles:** Can't find subtitles in your language? In the subtitle menu, choose **Search for more subtitles** to fetch matching SRT files instantly.

---

## 🛠️ Troubleshooting & FAQ

??? question "Media is buffering or playing choppy video"
    1. **Check Video Quality Settings:** If using Plex, ensure your player's Remote Quality is set to **Original / Maximum** as explained in the Plex setup guide. Transcoding high-bitrate video causes unnecessary buffer delays.
    2. **Subtitle Burning:** Certain bitmap subtitle formats (PGS/VOBSUB) force the server to burn subtitles directly into video frames. Switch the subtitle track to an **SRT / Text** subtitle track for instant Direct Play.
    3. **Connection Quality:** If streaming 4K HDR, ensure your streaming device has a strong, fast connection (prefer 5GHz Wi-Fi or wired Ethernet).

??? question "[Plex] Displays 'Indirect Connection' or 'Relay'"
    - An indirect connection indicates that your local router or network is having difficulty directly resolving our SSL domain.
    - Verify your internet connection, restart your streaming device, or test accessing [plex.unscfleet.com](https://plex.unscfleet.com) in your web browser.

??? question "[Jellyfin] Displays 'Unable to connect to server' or login fails"
    - Confirm the Server Address is typed exactly as:
      ```text
      https://jellyfin.unscfleet.com
      ```
    - Check that your username and password match what was provided by the Admin (credentials are case-sensitive).

??? question "Cannot find the movie I want to watch"
    - If a title is not currently in our library, you can request it with one click! Check out our [Content Request Guide](requests.md) to submit requests through our automated portal.
