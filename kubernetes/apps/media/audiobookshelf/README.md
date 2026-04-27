# Audiobookshelf Google OIDC Setup

**⚠️ SECURITY WARNING:** **NEVER** commit the `client_id` or `client_secret` to this file or any manifest. Save and Retrieve them from Bitwarden, 1Password, Azure Keyvault, etc.

## Overview

This guide documents the configuration of OpenID Connect (OIDC) for Audiobookshelf using Google as the identity provider. It allows Single Sign-On (SSO) for web and mobile clients.

## Phase 1: Google Cloud Console Setup

*Console URL:* [https://console.cloud.google.com/](https://console.cloud.google.com/)

### 1. Project Creation

1. Create a new project (e.g., `audiobookshelf`).
2. Navigate to **APIs & Services** > **OAuth consent screen**.

### 2. OAuth Consent Screen

* **User Type:** `External` (unless you have a Workspace org).
* **App Info:** Fill in App Name and Support Email.
* **Scopes:** Add the following three scopes:
  * `.../auth/userinfo.email`
  * `.../auth/userinfo.profile`
  * `openid`
* **Test Users (CRITICAL):**
  * > **🛑 IMPORTANT:** While the app is in "Testing" mode, **NO ONE** can log in unless their email is explicitly listed here.
  * Add your email
  * Add family/friends emails
  * *If you see "403: access_denied" during login, you forgot this step.*

### 3. Credentials (OAuth Client ID)

1. Go to **Credentials** > **+ Create Credentials** > **OAuth client ID**.
2. **Application Type:** `Web application`.
3. **Authorized Redirect URIs:**
    * You must add the full callback path for **every** domain used to access ABS.
    * **Web Callback:** `https://<YOUR_DOMAIN>/auth/openid/callback`
    * **Mobile Callback:** `https://<YOUR_DOMAIN>/auth/openid/mobile-redirect`

    *Example:*

    ```text
    https://audiobooks.mydomain.com/auth/openid/callback
    https://audiobooks.mydomain.com/auth/openid/mobile-redirect
    ```

4. **Save Secrets:**
    * Copy `Client ID` and `Client Secret`.

---

## Phase 2: Audiobookshelf Configuration

Location: `Settings` > `Authentication`

### 1. Provider Settings

* **Enable:** `OpenID Connect Authentication` (Checked)
* **Issuer URL:** `https://accounts.google.com` (Click "Auto-populate")
* **Client ID:** `<Copied from previous phase>`
* **Client Secret:** `<Copied from previous phase>`
* **Button Text:** `Login with Google`

### 2. Configuration Strategy

| Setting                  | Value                    | Reason                                                         |
|:-------------------------|:-------------------------|:---------------------------------------------------------------|
| **Signing Algorithm**    | `RS256`                  | Standard Google crypto signature.                              |
| **Match existing users** | `Email`                  | Links Google login to existing local admins.                   |
| **Mobile Redirect**      | `audiobookshelf://oauth` | **REQUIRED** for the iOS/Android app to catch the login token. |
| **Auto Register**        | *User Choice*            | Enable if you want family members to self-provision accounts.  |
| **Auto Launch**          | `Unchecked`              | Keep unchecked to allow local admin login fallback.            |

---

## Phase 3: User Mapping

If **Auto Register** is disabled, the Google email must **exactly match** an existing local user's email.

1. Log in as Admin (Local).
2. Go to **Settings** > **Users**.
3. Edit the target user (e.g., `Joshua`).
4. Set **Email** to the Google address.
5. Save.

---

## Troubleshooting

| Error                          | Cause                           | Fix                                                                              |
|:-------------------------------|:--------------------------------|:---------------------------------------------------------------------------------|
| **403: access_denied**         | Email not in "Test Users" list. | Go to Google Console > OAuth Consent Screen > Add User.                          |
| **400: redirect_uri_mismatch** | URL mismatch.                   | Ensure `https` vs `http` and `www` vs `non-www` match exactly in Google Console. |
| **Login Loop / Crash**         | User mapping failed.            | Ensure local ABS user has the *exact* same email address set in their profile.   |
