# @justrandomnickname/capacitor-app-version-manager

A Capacitor plugin for checking app versions and showing smart update notifications with intelligent scheduling.

## Features

✅ **Version Management** - Get current and App Store versions  
✅ **Semantic Versioning** - Proper version comparison (1.2.3 < 1.2.4)  
✅ **Native Alerts** - Beautiful native update dialogs  
✅ **Smart Scheduling** - Show notifications at controlled intervals (daily, weekly, monthly)  
✅ **Customizable UI** - Custom messages, titles, and button texts with placeholders  
✅ **Auto Country Detection** - Automatic region detection or manual override  

## Platform Support

| Platform | Status |
|----------|--------|
| iOS      | ✅ Full support |
| Android  | ⏳ Coming soon |
| Web      | ❌ Not supported |

## Install

```bash
npm install @justrandomnickname/capacitor-app-version-manager
npx cap sync
```

## Usage Examples

### Basic Usage

```typescript
import { AppVersionManager } from '@justrandomnickname/capacitor-app-version-manager';

// Simple check and notify
const { notified } = await AppVersionManager.notifyNewRelease();
if (notified) {
  console.log('User was notified about the update');
}
```

### Check for Updates (No UI)

```typescript
// Check if update is available without showing any UI
const { updateAvailable, app } = await AppVersionManager.checkForUpdate();

if (updateAvailable) {
  console.log(`New version ${app.release.version} is available!`);
  console.log(`Current version: ${app.current.version}`);
  
  // Show your custom UI or handle the update
}
```

### Get Version Information

```typescript
// Get detailed version info
const { app } = await AppVersionManager.getCurrentVersion();

console.log('Current version:', app.current.version);        // "1.2.3"
console.log('Current build:', app.current.buildNumber);      // "42"
console.log('Latest version:', app.release.version);         // "1.3.0"
console.log('Bundle ID:', app.bundleIdentifier);             // "com.example.app"
```

### Custom Messages with Placeholders

```typescript
// Use #current and #release placeholders
await AppVersionManager.notifyNewRelease({
  options: {
    title: "Update Available",
    message: "Version #release is now available! You're using #current.",
    buttonUpdateText: "Download Now",
    buttonCloseText: "Maybe Later"
  }
});

// Result: "Version 2.0.0 is now available! You're using 1.5.0."
```

### Smart Scheduling

```typescript
// Show notification at most once per week
await AppVersionManager.notifyNewRelease({
  options: {
    frequency: "weekly",
    message: "A new version (#release) is available!"
  }
});

// When user closes or clicks update → timer resets
// Won't show again for 7 days
```

### Check Scheduler Status

```typescript
// Get detailed information when notification is skipped
const result = await AppVersionManager.notifyNewRelease({
  options: { frequency: "monthly" }
});

if (result.skippedByScheduler) {
  console.log('Notification skipped by scheduler');
  console.log('Last shown:', result.schedulerDebugInfo?.lastNotificationDate);
  console.log('Days since:', result.schedulerDebugInfo?.daysSinceNotification);
}
```

### Force Notification

```typescript
// Show notification regardless of version comparison
await AppVersionManager.notifyNewRelease({
  options: {
    forceNotify: true, // Show even if versions are equal
    frequency: "daily",
    message: "Check out the new features!"
  }
});
```

### Custom App Store Link

```typescript
// Use a custom App Store URL
await AppVersionManager.notifyNewRelease({
  options: {
    appStoreLink: "https://apps.apple.com/us/app/myapp/id123456789",
    message: "Update available!"
  }
});
```

### Specify Country and Bundle ID

```typescript
// Useful for testing or multi-app scenarios
await AppVersionManager.notifyNewRelease({
  iosBundleId: "com.example.myapp",
  country: "us",
  options: {
    forceCountry: true, // Use specified country instead of auto-detect
    frequency: "weekly"
  }
});
```

### Complete Example

```typescript
import { AppVersionManager } from '@justrandomnickname/capacitor-app-version-manager';

async function checkAppUpdate() {
  try {
    const result = await AppVersionManager.notifyNewRelease({
      country: "us",
      options: {
        frequency: "weekly",
        title: "Update Available",
        message: "Version #release is available! You have #current installed.",
        buttonUpdateText: "Update",
        buttonCloseText: "Later",
        forceCountry: false
      }
    });
  } catch (error) {
    console.error('Error checking for updates:', error);
  }
}
```

### And actually you can you plugin something like this..

```typescript
import { AppVersionManager } from '@justrandomnickname/capacitor-app-version-manager';

async function notifyAboutCoffee() {
  try {
    const result = await AppVersionManager.notifyNewRelease({
      country: "us",
      options: {
        frequency: "weekly",
        title: "Wanna try delicious coffee?",
        message: "Go and buy it! Near you!",
        buttonUpdateText: "Buy coffee!",
        buttonCloseText: "No thanks...",
        appStoreLink: "https://coffeenearyou.coffeecompany.com"
        forceCountry: false
      }
    });
  } catch (error) {
    console.error('Error checking for updates:', error);
  }
}
```

## How It Works

### Notification Scheduling
- Stores last notification/dismiss date in `UserDefaults`
- Checks if enough time has passed before showing again
- Timer resets when user interacts with the alert (close or update)
- Frequency options: `always`, `daily`, `weekly`, `monthly`

### App Store Integration
- Automatically retrieves `trackId` from iTunes API
- Generates App Store URL: `itms-apps://itunes.apple.com/{country}/app/id{trackId}`
- Fallback to HTTPS URL for simulators
- Supports custom App Store links

## API

<docgen-index>

* [`getCurrentVersion(...)`](#getcurrentversion)
* [`checkForUpdate(...)`](#checkforupdate)
* [`notifyNewRelease(...)`](#notifynewrelease)
* [Interfaces](#interfaces)
* [Type Aliases](#type-aliases)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### getCurrentVersion(...)

```typescript
getCurrentVersion(options?: GetCurrentVersionProps | undefined) => any
```

Get the current app version information.

| Param         | Type                                                                      | Description                 |
| ------------- | ------------------------------------------------------------------------- | --------------------------- |
| **`options`** | <code><a href="#getcurrentversionprops">GetCurrentVersionProps</a></code> | Get current version options |

**Returns:** <code>any</code>

**Since:** 1.0.0

--------------------


### checkForUpdate(...)

```typescript
checkForUpdate(options?: GetCurrentVersionProps | undefined) => any
```

Check for updates without showing any alert.

| Param         | Type                                                                      | Description                 |
| ------------- | ------------------------------------------------------------------------- | --------------------------- |
| **`options`** | <code><a href="#getcurrentversionprops">GetCurrentVersionProps</a></code> | Get current version options |

**Returns:** <code>any</code>

**Since:** 1.0.0

--------------------


### notifyNewRelease(...)

```typescript
notifyNewRelease(options?: NotifyNewReleaseProps | undefined) => any
```

Check for updates and show a native alert if a new version is available.
Supports scheduling to avoid showing notifications too frequently.

| Param         | Type                                                                    | Description                |
| ------------- | ----------------------------------------------------------------------- | -------------------------- |
| **`options`** | <code><a href="#notifynewreleaseprops">NotifyNewReleaseProps</a></code> | Notify new release options |

**Returns:** <code>any</code>

**Since:** 1.0.0

--------------------


### Interfaces


#### GetCurrentVersionProps

| Prop              | Type                                                                          | Description                                               | Since |
| ----------------- | ----------------------------------------------------------------------------- | --------------------------------------------------------- | ----- |
| **`iosBundleId`** | <code>string</code>                                                           | iOS Bundle Identifier of the app.                         | 1.0.0 |
| **`country`**     | <code>string</code>                                                           | Country code for App Store link (e.g., "us", "gb", "de"). | 1.0.0 |
| **`options`**     | <code><a href="#getcurrentversionoptions">GetCurrentVersionOptions</a></code> | Options for getting the current version.                  | 1.0.0 |


#### GetCurrentVersionOptions

Options for getting the current app version.

| Prop               | Type                 | Description                                               | Since |
| ------------------ | -------------------- | --------------------------------------------------------- | ----- |
| **`country`**      | <code>string</code>  | Country code for App Store link (e.g., "us", "gb", "de"). | 1.0.0 |
| **`forceCountry`** | <code>boolean</code> | Force the use of the specified country code.              | 1.0.0 |


#### AppInfo

Information about the app versions.

| Prop                   | Type                                        | Description                                         | Since |
| ---------------------- | ------------------------------------------- | --------------------------------------------------- | ----- |
| **`current`**          | <code><a href="#version">Version</a></code> | Current installed version of the app.               | 1.0.0 |
| **`release`**          | <code><a href="#version">Version</a></code> | Latest released version available in the App Store. | 1.0.0 |
| **`bundleIdentifier`** | <code>string</code>                         | iOS Bundle Identifier of the app.                   | 1.0.0 |


#### Version

<a href="#version">Version</a> information of the app.

| Prop                | Type                | Description                                            |
| ------------------- | ------------------- | ------------------------------------------------------ |
| **`buildNumber`**   | <code>string</code> | Build number (e.g., "100").                            |
| **`version`**       | <code>string</code> | <a href="#version">Version</a> number (e.g., "1.0.0"). |
| **`versionString`** | <code>string</code> | Full version string (e.g., "1.0.0 (100)").             |


#### NotifyNewReleaseProps

| Prop              | Type                                                                        | Description                                               | Since |
| ----------------- | --------------------------------------------------------------------------- | --------------------------------------------------------- | ----- |
| **`iosBundleId`** | <code>string</code>                                                         | iOS Bundle Identifier of the app.                         | 1.0.0 |
| **`country`**     | <code>string</code>                                                         | Country code for App Store link (e.g., "us", "gb", "de"). | 1.0.0 |
| **`options`**     | <code><a href="#notifynewreleaseoptions">NotifyNewReleaseOptions</a></code> | Options for notifying about a new release.                | 1.0.0 |


#### NotifyNewReleaseOptions

| Prop                   | Type                                            | Description                                                                                                                                                                            | Since |
| ---------------------- | ----------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----- |
| **`message`**          | <code>string</code>                             | Message of the update alert.                                                                                                                                                           | 1.0.0 |
| **`title`**            | <code>string</code>                             | Title of the update alert.                                                                                                                                                             | 1.0.0 |
| **`frequency`**        | <code><a href="#frequency">Frequency</a></code> | <a href="#frequency">Frequency</a> of showing update notifications.                                                                                                                    | 1.0.0 |
| **`buttonCloseText`**  | <code>string</code>                             | Text for the button that closes the alert.                                                                                                                                             | 1.0.0 |
| **`buttonUpdateText`** | <code>string</code>                             | Text for the button that updates the app.                                                                                                                                              | 1.0.0 |
| **`forceNotify`**      | <code>boolean</code>                            |                                                                                                                                                                                        |       |
| **`appStoreLink`**     | <code>string</code>                             | Link to the app store page for the app.                                                                                                                                                | 1.0.0 |
| **`critical`**         | <code><a href="#semver">SemVer</a></code>       | Indicates if the update is critical and should be forced to install. For example if set to 'major', UI will be blocked if: - The current version is less than the latest major version | 1.0.3 |


#### SchedulerDebugInfo

Debug information about the scheduler used for notifications.

| Prop                        | Type                                            | Description                                                                     | Since |
| --------------------------- | ----------------------------------------------- | ------------------------------------------------------------------------------- | ----- |
| **`frequency`**             | <code><a href="#frequency">Frequency</a></code> | The frequency setting used for scheduling notifications.                        | 1.0.0 |
| **`shouldShow`**            | <code>boolean</code>                            | Indicates whether a notification should be shown based on the scheduling rules. | 1.0.0 |
| **`lastNotificationDate`**  | <code>string</code>                             | The date when the last notification was shown, if available.                    | 1.0.0 |
| **`lastDismissDate`**       | <code>string</code>                             | The date when the last notification was dismissed, if available.                | 1.0.0 |
| **`daysSinceNotification`** | <code>number</code>                             | The number of days since the last notification was shown.                       | 1.0.0 |
| **`daysSinceDismiss`**      | <code>number</code>                             | The number of days since the last notification was dismissed.                   | 1.0.0 |


### Type Aliases


#### Frequency

<a href="#frequency">Frequency</a> options for update notifications.
Available options: "always", "daily", "weekly", "monthly".

<code>"always" | "daily" | "weekly" | "monthly"</code>


#### SemVer

<code>'major' | 'minor' | 'patch'</code>

</docgen-api>
