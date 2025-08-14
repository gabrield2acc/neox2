# acc-neox2

An iOS SwiftUI app that helps users install a Passpoint/Hotspot 2.0 profile from `profiles.acloudradius.net`, and displays a marketing section that switches from a default neoX2 theme to a SONY theme after connecting to Wi‑Fi presumed to be enabled by the installed Passpoint profile.

## Features
- Open `https://profiles.acloudradius.net` in the default browser to trigger iOS profile installation.
- Marketing section with two visual states:
  - Default neoX2 (blue/black/white)
  - SONY (activates when Wi‑Fi connectivity is detected and heuristics indicate network is active)
- Heuristics to infer Wi‑Fi state using `NWPathMonitor`, and optional SSID access when location is granted.

## Important platform notes
- iOS does not expose the NAI Realm advertised by an Access Point to third‑party apps unless granted the private HotspotHelper entitlement (not available for App Store distribution). Because of this, the app cannot directly “detect the NAI Realm (acloudradius.net) advertised by the AP)”.
- As a pragmatic alternative, this app:
  - Detects when the device is on Wi‑Fi and
  - Optionally reads the current SSID if the user grants Location permission and the Access Wi‑Fi Information capability is active
  - Performs a lightweight reachability check while on Wi‑Fi
  - If those conditions pass, it switches the ad image to SONY

If you can obtain Apple’s HotspotHelper entitlement for your bundle ID, we can replace the heuristic with a direct ANQP/NAI realm read.

### Enabling realm-based switching (optional, requires entitlement)
- Define the Swift flag `HOTSPOT_HELPER_ENABLED` for the target (Build Settings > Other Swift Flags: `-D HOTSPOT_HELPER_ENABLED`).
- Add the private entitlement `com.apple.developer.networking.HotspotHelper` to the app (Apple-approved builds only).
- Implement realm parsing in `HotspotHelperRealmDetector` (currently a stub). When the detected realm contains `sony.net`, the ad will switch to the AI-styled SONY view.

### Realm probe endpoint (server-assisted)
The app is configured to query your hosted endpoint:

- `RealmProbeURL` (Info.plist): `https://probe.acloudradius.net/realm`
- Expected response: JSON `{ "realm": "sony.net" }` (plaintext `sony.net` is also supported)
- When on Wi‑Fi, the app calls this probe and switches the ad to SONY if it returns `sony.net`.

## Project structure
- `NeoX2.xcodeproj` – Xcode project with a single SwiftUI app target
- `NeoX2/` – app sources
  - `App/NeoX2App.swift` – app entry
  - `App/ContentView.swift` – UI with profile button and ad section
  - `App/AppState.swift` – connectivity + ad switching logic
  - `App/LocationManager.swift` – location permission helper (for SSID access)
  - `Resources/Info.plist` – Info plist with required permissions
  - `Resources/NeoX2.entitlements` – entitlements for Hotspot Configuration and Access Wi‑Fi Information
- `.github/workflows/ios.yml` – CI to build and (optionally) sign/upload

## Build and run (local)
1. Open `NeoX2.xcodeproj` in Xcode 15+
2. Select an iOS Simulator or device and run
3. On device, to allow SSID access, accept the location permission prompt when asked

## GitHub Actions and signing
The workflow includes a CI build job (simulator) and a release job for TestFlight using Apple ID + app-specific password and manual signing.

Configure these repo secrets:
- `KEYCHAIN_PASSWORD` – Password used to create the temporary build keychain
- `APPLE_DISTRIBUTION_CERTIFICATE` – Base64-encoded `.p12` distribution certificate
- `CERTIFICATE_PASSWORD` – Password for the above `.p12`
- `PROVISIONING_PROFILE` – Base64-encoded `.mobileprovision`
- `PROVISIONING_PROFILE_NAME` – The exact Provisioning Profile name (specifier)
- `CODE_SIGN_IDENTITY` – e.g., `Apple Distribution: Your Company (TEAMID)`
- `DEVELOPMENT_TEAM` – Your Apple Team ID
- `APPLE_ID` – Your Apple ID (for Transporter)
- `APPLE_APP_SPECIFIC_PASSWORD` – App-specific password for that Apple ID

Push a tag like `v1.0.0` to trigger the release job.

Signing requirements
- Bundle ID: `net.acloudradius.neox2`
- Provisioning profile: App Store profile for `net.acloudradius.neox2` on your team
- Code signing identity (matches your imported distribution certificate)

## Profile installation guide
See the in-app "Profile Setup" screen. It provides step-by-step guidance inspired by Cloud4Wi’s Passpoint portal documentation and opens `https://profiles.acloudradius.net` to download the profile, with a shortcut to app settings for granting Location access.

##

## Repository creation
Create the GitHub repository named `acc-neox2` and push this project:

```bash
git init
git add .
git commit -m "feat: initial neoX2 iOS app"
git branch -M main
git remote add origin git@github.com:<your-org-or-user>/acc-neox2.git
git push -u origin main
```

Alternatively, use GitHub CLI:

```bash
gh repo create acc-neox2 --public --source=. --remote=origin --push
```

## Next steps
- Provide SSID(s) for the Passpoint network to tighten the heuristic (e.g., switch to SONY only if connected SSID matches expected broadcast).
- If you have HotspotHelper entitlement, we can integrate true NAI Realm detection and replace the heuristic.
