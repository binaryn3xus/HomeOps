# 🎧 Audiobooks & Podcasts

UNSC Fleet hosts a dedicated **Audiobookshelf** streaming server. Enjoy a curated library of audiobooks, dramas, and podcasts with chapter navigation, variable playback speeds, sleep timers, and cross-device listening progress sync.

---

## 📚 Listening Options

### 🌐 Web Player
Listen directly in any modern browser without installing any software:

[Open Audiobooks Web Player :material-headphones:](https://audiobooks.unscfleet.com){ .md-button .md-button--primary target="_blank" }

---

## 📱 Mobile Apps

Download dedicated client apps with offline caching, sleep timers, lock screen media controls, and car head unit integrations.

=== "Android"

    The official **Audiobookshelf** client is available on Google Play for all modern Android phones, tablets, and head units.

    [Download on Google Play :material-google-play:](https://play.google.com/store/apps/details?id=com.audiobookshelf.app){ .md-button target="_blank" }

    #### Highlights
    - **Native Android Auto:** Browse your library and control playback safely from your car's dashboard.
    - **Background Audio:** Full support for lock screen controls and Bluetooth media button toggles.
    - **Offline Playback:** Download books in full or chapter-by-chapter for flights and road trips.
    - **Sleep Timer:** Shake phone to extend sleep timer.

=== "Apple (iOS / iPadOS)"

    iOS users have multiple polished client options:

    [Download Absorb for iOS :material-apple:](https://apps.apple.com/us/app/absorb-for-audiobookshelf/id6760673498){ .md-button target="_blank" }

    #### Highlights
    - **Apple CarPlay Support:** Native CarPlay interface for safe listening while commuting.
    - **Progress Sync:** Matches your exact listening position between your iPhone, iPad, and the web app.
    - **Offline Downloads:** Download full audiobooks with custom storage management.

    !!! tip "Progressive Web App (PWA) Alternative"
        You can also open [https://audiobooks.unscfleet.com](https://audiobooks.unscfleet.com) in Safari on iOS, tap the **Share** button (box with upward arrow), and select **Add to Home Screen**. This installs the official web app directly to your home screen with full offline caching support!

---

## 🔑 How to Connect Your App

1. Launch **Audiobookshelf** (Android) or **Absorb** (iOS).
2. In the **Server Address** input field, enter:
   ```text
   https://audiobooks.unscfleet.com
   ```
3. Tap **Sign in with Google**.
4. Authenticate using your Google account.
5. Upon authorization, your personal audiobook library will load automatically!

!!! important "Google Account Authorization Required"
    Before signing in for the first time, send your Google account email address to an **Admin**. Your email must be whitelisted on the server before Google OAuth will permit access.

---

## 💡 Listening Tips & Features

- **Variable Playback Speed:** Fine-tune audio speeds from `0.5x` to `3.0x` with pitch preservation so narrators always sound natural.
- **Sleep Timer:** Set a timer before bed (e.g. 15, 30, or 60 minutes, or until the end of the current chapter). The **Shake to Extend** feature allows you to gently shake your device to reset the timer without looking at the screen.
- **Bookmarks & Notes:** Tap the bookmark icon to mark memorable moments or quotes with custom timestamps and text notes.

---

## 🛠️ Troubleshooting & FAQ

??? question "Error: '403 Forbidden' or 'User not authorized' during Google Login"
    - This error occurs when your Google email address hasn't been added to our server's permitted user list.
    - Contact **BinaryNexus** with your Google email address to have your account provisioned.

??? question "Downloads pause or fail while downloading on iOS"
    - iOS aggressively pauses background network tasks if an app is minimized and the screen locks.
    - Keep **Absorb** or Safari in the foreground while downloading large audiobooks until the download progress reaches 100%.
    - In iOS **Settings** → **Absorb**, make sure **Background App Refresh** is toggled **On**.

??? question "Listening progress didn't sync to another device"
    - Confirm both devices are connected to the internet.
    - In the app, pull down on your library view to trigger a manual sync with the server before closing the app.
