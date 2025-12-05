/**
 * Version information of the app.
 * @since 1.0.0
 */
export interface Version {
  /**
   * Build number (e.g., "100").
   */
  buildNumber: string;
  /**
   * Version number (e.g., "1.0.0").
   */
  version: string;
  /**
   * Full version string (e.g., "1.0.0 (100)").
   */
  versionString: string;
}

/**
 * Information about the app versions.
 * @since 1.0.0
 */
export interface AppInfo {
  /**
   * Current installed version of the app.
   * @since 1.0.0
   */
  current: Version;
  /**
   * Latest released version available in the App Store.
   * @since 1.0.0
   */
  release: Version;
  /**
   * iOS Bundle Identifier of the app.
   * @since 1.0.0
   */
  bundleIdentifier: string;
}

/**
 * Frequency options for update notifications.
 * Available options: "always", "daily", "weekly", "monthly".
 * @since 1.0.0
 */
export type Frequency = "always" | "daily" | "weekly" | "monthly";

/**
 * Options for getting the current app version.
 * @since 1.0.0
 */
export interface GetCurrentVersionOptions {
  /**
   * Country code for App Store link (e.g., "us", "gb", "de").
   * @since 1.0.0
   */
  country?: string;
  /**
   * Force the use of the specified country code.
   * @since 1.0.0
   */
  forceCountry?: boolean;
}

export interface NotifyNewReleaseOptions extends GetCurrentVersionOptions {
  /** Message of the update alert.
   * @since 1.0.0
   */
  message?: string;
  /** Title of the update alert.
   * @since 1.0.0
   */
  title?: string;
  /**
   * Frequency of showing update notifications.
   * @since 1.0.0
   */
  frequency?: Frequency;
  /**
   * Text for the button that closes the alert.
   * @since 1.0.0
   */
  buttonCloseText?: string;
  /**
   * Text for the button that updates the app.
   * @since 1.0.0
   */
  buttonUpdateText?: string;
  /**
   * Text for the button that forces the update.
   * @since 1.0.0
   */
  buttonForceUpdateText?: string;
  forceNotify?: boolean;
  /**
   * Link to the app store page for the app.
   * @since 1.0.0
   */
  appStoreLink?: string;
}

export interface GetCurrentVersionProps {
  /** iOS Bundle Identifier of the app.
   * @since 1.0.0
   */
  iosBundleId?: string;
  /**
   * Country code for App Store link (e.g., "us", "gb", "de").
   * @since 1.0.0
   */
  country?: string;
  /**
   * Options for getting the current version.
   * @since 1.0.0
   */
  options?: GetCurrentVersionOptions;
}

export interface NotifyNewReleaseProps {
  /**
   * iOS Bundle Identifier of the app.
   * @since 1.0.0
   */
  iosBundleId?: string;
  /**
   * Country code for App Store link (e.g., "us", "gb", "de").
   * @since 1.0.0
   */
  country?: string;
  /**
   * Options for notifying about a new release.
   * @since 1.0.0
   */
  options?: NotifyNewReleaseOptions;
}

/**
 * Debug information about the scheduler used for notifications.
 * @since 1.0.0
 */
export interface SchedulerDebugInfo {
  /**
   * The frequency setting used for scheduling notifications.
   * @since 1.0.0
   */
  frequency: Frequency;
  /**
   * Indicates whether a notification should be shown based on the scheduling rules.
   * @since 1.0.0
   */
  shouldShow: boolean;
  /**
   * The date when the last notification was shown, if available.
   * @since 1.0.0
   */
  lastNotificationDate?: string;
  /**
   * The date when the last notification was dismissed, if available.
   * @since 1.0.0
   */
  lastDismissDate?: string;
  /**
   * The number of days since the last notification was shown.
   * @since 1.0.0
   */
  daysSinceNotification?: number;
  /**
   * The number of days since the last notification was dismissed.
   * @since 1.0.0
   */
  daysSinceDismiss?: number;
}

export interface NotifyNewReleaseResult {
  /**
   * Indicates whether the user was notified about the new release.
   * @since 1.0.0
   */
  notified: boolean;
  /**
   * Information about the app versions.
   * @since 1.0.0
   */
  app: AppInfo;
  /**
   * Indicates whether the notification was skipped by the scheduler.
   * @since 1.0.0
   */
  skippedByScheduler?: boolean;
  /**
   * Debug information about the notification scheduler.
   * @since 1.0.0
   */
  schedulerDebugInfo?: SchedulerDebugInfo;
}

export interface AppVersionManagerPlugin {
  /**
   * Get the current app version information.
   * @param options Get current version options
   * @since 1.0.0
   * @returns { Promise<{ app: AppInfo }> } A promise that resolves with the app info
   */
  getCurrentVersion(options?: GetCurrentVersionProps): Promise<{ app: AppInfo }>;

  /**
   * Check for updates without showing any alert.
   * @since 1.0.0
   * @param { GetCurrentVersionProps } options Get current version options
   * @returns { Promise<{ updateAvailable: boolean; app: AppInfo }> } A promise that resolves with update availability and app info
   */
  checkForUpdate(options?: GetCurrentVersionProps): Promise<{ 
    updateAvailable: boolean; 
    app: AppInfo 
  }>;
  /**
   * Check for updates and show a native alert if a new version is available.
   * Supports scheduling to avoid showing notifications too frequently.
   * @since 1.0.0
   * @param { NotifyNewReleaseProps } options Notify new release options
   * @returns { Promise<NotifyNewReleaseResult> }
   */
  notifyNewRelease(options?: NotifyNewReleaseProps): Promise<{ 
    notified: boolean; 
    app: AppInfo;
    skippedByScheduler?: boolean;
    schedulerDebugInfo?: SchedulerDebugInfo;
  }>;
}