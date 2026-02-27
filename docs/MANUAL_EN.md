# Beep User Manual (English)

> Cross-platform Hourly Chime & Timer Application

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [Environment Setup](#2-environment-setup)
3. [Project Structure](#3-project-structure)
4. [Development & Running](#4-development--running)
5. [Features](#5-features)
6. [Building & Release](#6-building--release)
7. [FAQ](#7-faq)

---

## 1. Introduction

**Beep** is a cross-platform application built with Flutter, supporting:

- ✅ macOS (Intel and Apple Silicon)
- ✅ Android
- ✅ iOS
- ✅ Web

### Core Features

| Feature | Description |
|---------|-------------|
| Hourly Chime | Automatic hourly reminders with quiet hours support |
| Custom Timers | Create one-time or daily recurring reminders |
| System Notifications | Push notifications with sound alerts |
| Theme Switching | Light/Dark/System themes |

---

## 2. Environment Setup

### 2.1 Required Tools

| Tool | Version | Purpose |
|------|---------|---------|
| Flutter SDK | 3.24.0+ | Development framework |
| Dart | 3.5.0+ | Programming language (bundled with Flutter) |

### 2.2 Platform-Specific Requirements

| Target Platform | Requirements |
|-----------------|--------------|
| Web | Chrome browser only |
| macOS | Xcode 15.0+ |
| iOS | Xcode 15.0+ + iOS Simulator |
| Android | Android Studio + Android SDK |

### 2.3 Installing Flutter

**Option 1: Using Homebrew (macOS)**

```bash
brew install --cask flutter
```

**Option 2: Manual Download**

```bash
# Download Flutter SDK
curl -L -o flutter.zip "https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_3.24.0-stable.zip"

# Extract to home directory
unzip -q flutter.zip -d ~
rm flutter.zip

# Add to PATH (append to ~/.zshrc)
export PATH="$HOME/flutter/bin:$PATH"

# Apply changes
source ~/.zshrc
```

### 2.4 Verify Installation

```bash
flutter doctor
```

---

## 3. Project Structure

```
beep/
├── lib/                          # Source code
│   ├── main.dart                 # App entry point
│   ├── app.dart                  # App configuration (theme, i18n)
│   ├── core/                     # Core services
│   │   ├── scheduler/            # Scheduling module
│   │   │   └── chime_scheduler.dart
│   │   ├── notification/         # Notification module
│   │   │   └── notification_service.dart
│   │   └── audio/                # Audio module
│   │       └── audio_service.dart
│   ├── data/                     # Data layer
│   │   ├── models/               # Data models
│   │   │   ├── timer_model.dart
│   │   │   └── settings_model.dart
│   │   └── repositories/         # Data repositories
│   │       └── settings_repository.dart
│   └── ui/                       # UI layer
│       ├── screens/              # Screens
│       │   ├── home_screen.dart
│       │   ├── settings_screen.dart
│       │   ├── add_timer_screen.dart
│       │   └── edit_timer_screen.dart  # Edit timer screen
│       ├── widgets/              # Reusable widgets
│       │   ├── clock_display.dart
│       │   ├── chime_status_card.dart
│       │   └── timer_list_card.dart
│       └── state/                # State management
│           ├── settings_state.dart
│           └── timer_state.dart
├── assets/                       # Asset files
│   └── sounds/                   # Sound files
│       ├── chime.mp3
│       └── timer.mp3
├── android/                      # Android native config
├── ios/                          # iOS native config
├── macos/                        # macOS native config
├── web/                          # Web config
├── docs/                         # Documentation
├── pubspec.yaml                  # Dependencies
└── README.md                     # Project readme
```

---

## 4. Development & Running

### 4.1 Get Dependencies

```bash
cd /Users/sv/codes/beep
flutter pub get
```

### 4.2 Run the App

**Web (Recommended for quick testing)**

```bash
flutter run -d chrome
```

**macOS**

```bash
# Requires Xcode
flutter run -d macos
```

**Android**

```bash
# Requires Android Studio and Android SDK
# List available devices
flutter devices

# Run on specific device
flutter run -d <device_id>
```

**iOS**

```bash
# Requires Xcode
# Launch iOS Simulator
open -a Simulator

# Run
flutter run -d <simulator_id>
```

### 4.3 Hot Reload

While running, use these keyboard shortcuts:

| Key | Action |
|-----|--------|
| `r` | Hot reload (preserves state) |
| `R` | Hot restart (resets state) |
| `q` | Quit |
| `h` | Help |

---

## 5. Features

### 5.1 Hourly Chime

**How it works:**
1. App calculates time until next hour boundary
2. Sets a timer to trigger at that moment
3. On trigger: plays sound + shows notification
4. Automatically schedules next hour

**Settings:**
- Toggle: Enable/disable hourly chime
- Quiet Hours: Set time range when chimes are silenced (e.g., 10 PM - 7 AM)

### 5.2 Custom Timers

**Supported modes:**
- One-time: Triggers once at specified time
- Daily: Triggers every day at specified time

**Creating a Timer:**
1. Tap the "Add Timer" button (bottom right)
2. Enter a label (e.g., "Take medication")
3. Select time
4. Choose repeat mode
5. Tap "Save"

**Editing a Timer:**
1. Tap on a timer card or tap the edit icon (pencil)
2. Modify the label, time, or repeat mode
3. Tap "Save" to apply changes
4. If there are unsaved changes, you'll be prompted to discard or keep editing

**Deleting a Timer:**

Option 1: Swipe to Delete
- Swipe left on a timer card to delete immediately

Option 2: Delete from Edit Screen
- Enter edit screen, tap the delete icon at the top or the "Delete Timer" button at the bottom
- Confirm deletion - the timer will be permanently removed

Option 3: Long Press Menu
- Long press on a timer card to show context menu
- Select "Delete" and confirm

**Managing Timers:**
- Toggle switch: Tap the switch on the right to enable/disable individual timers
- Long press menu: Shows "Edit", "Toggle", and "Delete" options

### 5.3 Settings

| Setting | Description |
|---------|-------------|
| Enable Hourly Chime | Turn hourly chime on/off |
| Quiet Hours | Set silent period |
| Volume | Adjust notification volume |
| Vibration | Enable/disable vibration (mobile) |
| Theme | Switch between Light/Dark/System |
| 24-Hour Format | Use 24-hour time display |

---

## 6. Building & Release

### 6.1 Web Build

```bash
# Build
flutter build web --release

# Output directory
build/web/
```

Deploy: Upload contents of `build/web/` to any static file server.

### 6.2 Android Build

**Prerequisites:**
1. Install Android Studio
2. Install Android SDK
3. Configure `flutter config --android-sdk <path>`
4. Accept licenses `flutter doctor --android-licenses`

```bash
# Build APK (for testing)
flutter build apk --release

# Output file
build/app/outputs/flutter-apk/app-release.apk

# Build App Bundle (for Google Play)
flutter build appbundle --release
```

### 6.3 iOS Build

**Prerequisites:**
1. Install Xcode
2. Apple Developer account (required for App Store)

```bash
# Build
flutter build ios --release

# Archive using Xcode
open ios/Runner.xcworkspace
```

### 6.4 macOS Build

```bash
# Build
flutter build macos --release

# Output directory
build/macos/Build/Products/Release/beep.app
```

---

## 7. Publishing to App Stores

### 7.1 Google Play Store (Android)

**Prerequisites**

| Item | Requirement |
|------|-------------|
| Developer Account | One-time $25 registration fee |
| Signing Key | For signing APK/AAB |
| App Icon | 512x512 PNG |
| Screenshots | At least 2 per screen size |
| Privacy Policy | URL required |

**Generate Signing Key**

```bash
keytool -genkey -v -keystore ~/beep-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias beep
```

**Configure Signing (android/key.properties)**

```properties
storePassword=your_password
keyPassword=your_password
keyAlias=beep
storeFile=/Users/your_username/beep-release-key.jks
```

**Build and Upload**

```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

Visit https://play.google.com/console → Create app → Upload AAB → Submit for review (1-3 days)

---

### 7.2 Apple App Store (iOS/macOS)

**Prerequisites**

| Item | Requirement |
|------|-------------|
| Apple Developer Account | $99/year (Individual) / $299/year (Organization) |
| Mac Computer | Xcode required |
| Certificates & Profiles | Distribution Certificate + Provisioning Profile |
| App Icon | 1024x1024 PNG |
| Screenshots | iPhone 6.5", 5.5", iPad sizes |
| Privacy Policy | URL required |

**Configuration Steps**

1. Log in to https://developer.apple.com
2. Certificates → Create Distribution Certificate
3. Identifiers → Create App ID (com.beep.beep)
4. Profiles → Create App Store Distribution Profile

**Build and Archive**

```bash
flutter build ios --release
open ios/Runner.xcworkspace
# In Xcode: Product → Archive → Distribute App → App Store Connect
```

Visit https://appstoreconnect.apple.com → Create App → Submit for review (1-2 days)

---

### 7.3 China Android App Stores

China does not have Google Play. Apps must be published to multiple stores:

**Major App Stores**

| Store | Market Share | Registration URL | Individual Dev |
|-------|--------------|------------------|----------------|
| Huawei AppGallery | ~40% | https://developer.huawei.com | ⚠️ Partial |
| Xiaomi App Store | ~15% | https://dev.mi.com | ✅ Yes |
| OPPO App Market | ~12% | https://open.oppomobile.com | ⚠️ Enterprise |
| vivo App Store | ~12% | https://dev.vivo.com.cn | ⚠️ Enterprise |
| Tencent MyApp | ~10% | https://open.qq.com | ❌ Enterprise |
| Coolapk | ~3% | https://www.coolapk.com | ✅ Yes |

**Prerequisites for China**

| Item | Description |
|------|-------------|
| Business License | Most stores require enterprise registration |
| Software Copyright | Some stores require (Huawei, MyApp) |
| Real-name Verification | All stores require |
| Privacy Policy | Must comply with PIPL (Personal Information Protection Law) |

**Build APK (China stores use APK, not AAB)**

```bash
flutter build apk --release --split-per-abi

# Output:
# build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk (older devices)
# build/app/outputs/flutter-apk/app-arm64-v8a-release.apk   (mainstream)
```

**Recommended Publishing Order (Individual Developers)**

1. Xiaomi App Store (individual-friendly)
2. Coolapk (indie developer community)
3. Huawei AppGallery (largest market share)

---

### 7.4 Review Rejection Common Reasons

| Platform | Common Rejection Reasons |
|----------|-------------------------|
| Google Play | Insufficient permission explanation, missing privacy policy, crashes |
| App Store | UI doesn't follow HIG, incomplete features, inaccurate metadata |
| China Stores | Missing privacy policy, no permission prompts, PIPL non-compliance |

---

## 8. Auto-Start & Background Keep-Alive

### 8.1 Android Background Keep-Alive

Beep uses the following strategies to ensure hourly chimes are not killed by the system:

| Strategy | Effectiveness | Description |
|----------|---------------|-------------|
| Foreground Service | ⭐⭐⭐⭐⭐ | Shows persistent notification, most effective |
| Battery Optimization Exemption | ⭐⭐⭐⭐ | Reduces Doze mode restrictions |
| Exact Alarms | ⭐⭐⭐⭐ | System-level wake-up |
| Boot Auto-Start | ⭐⭐⭐ | Restores service after reboot |

**Configured Permissions:**

```xml
RECEIVE_BOOT_COMPLETED    <!-- Auto-start on boot -->
FOREGROUND_SERVICE        <!-- Foreground service -->
SCHEDULE_EXACT_ALARM      <!-- Exact alarms -->
REQUEST_IGNORE_BATTERY_OPTIMIZATIONS  <!-- Battery exemption -->
WAKE_LOCK                 <!-- Wake lock -->
```

### 8.2 China ROM Special Settings

Chinese phone brands (Huawei, Xiaomi, OPPO, vivo, etc.) have additional auto-start management that requires manual user authorization:

| Brand | Settings Path |
|-------|--------------|
| Xiaomi/Redmi | Settings → Apps → Manage apps → Beep → Auto-start |
| Huawei/Honor | Settings → Apps → App launch → Beep → Manage manually |
| OPPO/realme | Settings → App management → App list → Beep → Power saver |
| vivo/iQOO | Settings → Battery → Background power consumption → Allow Beep |
| OnePlus | Settings → Battery → Battery optimization → Beep → Don't optimize |

### 8.3 iOS Limitations

iOS does not support true background persistence, but Beep uses these alternatives:

| Approach | Description |
|----------|-------------|
| Local Notifications | Schedule hourly notifications in advance, no background needed |
| Background Refresh | System occasionally wakes app to refresh data |
| Silent Push | Server-triggered (requires backend support) |

> **Note:** iOS hourly chimes rely on system notifications, which may have a few seconds of delay.

### 8.4 macOS/Web

- **macOS**: Apps can stay running in background, no special restrictions
- **Web**: Only works while browser tab is open

---

## 9. FAQ

### Q1: flutter command not found

Add Flutter to PATH:

```bash
export PATH="$HOME/flutter/bin:$PATH"
```

### Q2: Slow/timeout downloads

Use China mirror (if in China):

```bash
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
export PUB_HOSTED_URL=https://pub.flutter-io.cn
```

### Q3: Android SDK not found

```bash
flutter config --android-sdk /Users/$USER/Library/Android/sdk
flutter doctor --android-licenses
```

### Q4: Xcode command line tools issue

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

### Q5: Dependency version conflict

```bash
flutter pub upgrade
flutter pub get
```

### Q6: Web notifications not working

Web platform notifications require:
1. HTTPS or localhost
2. User permission grant

### Q7: Lost signing key?

**Important:** If you lose your signing key, you cannot update published apps!

Recommendations:
1. Backup `beep-release-key.jks` to a secure location
2. Store password in a password manager
3. Use Google Play App Signing (managed signing)

### Q8: App rejected by store?

Common reasons:
- Missing or incomplete privacy policy
- Permission requests not explained
- App crashes or severe bugs
- Screenshots don't match actual functionality

### Q9: Hourly chime inaccurate or missing?

**Android:**
1. Check if auto-start permission is enabled
2. Check battery optimization settings, set Beep to "Don't optimize"
3. Lock app in recent tasks (swipe down to lock)

**iOS:**
- iOS notifications may have a few seconds delay, this is a system limitation

### Q10: How to disable the persistent notification?

The foreground service notification is essential for keep-alive. Disabling it may cause missed chimes.
If you must: Settings → Apps → Beep → Notifications → Disable "Beep Service" channel

---

## Support

For issues, please submit a GitHub Issue or contact the developer.

---

*Document Version: 1.1.0*  
*Last Updated: 2026-02-09*
