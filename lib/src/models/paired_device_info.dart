part of models;

class WatchOsPairedDeviceInfo {
  /// The value of this property is true when the iPhone is paired to an Apple Watch or false when it is not.
  ///
  /// The value in this property is valid only for a configured session that has been activated successfully. If the [ActivationState] property is available, its value must be [ActivationState.activated]. When the session becomes inactive or deactivated, you should ignore the value in this property.
  final bool isPaired;

  ///The user can choose to install only a subset of available apps on Apple Watch. The value of this property is true when the Watch app associated with the current iOS app is installed on the user’s Apple Watch or false when it is not installed.
  ///
  ///The value in this property is valid only for a configured session that has been activated successfully. If the [ActivationState] property is available, its value must be [ActivationState.activated]. When the session becomes inactive or deactivated, you should ignore the value in this property.
  final bool isWatchAppInstalled;

  ///The value of this property is true when the app’s complication is installed on the active clock face. When the value of this property is false, calls to the [transferUserInfo(userInfo: userInfo, isComplication: true)] method fail immediately.
  final bool isComplicationEnabled;

  ///You must activate the current session before accessing this URL. Use this directory to store preferences, files, and other data that is relevant to the specific instance of your Watch app running on the currently paired Apple Watch. If more than one Apple Watch is paired with the same iPhone, the URL in this directory changes when the active Apple Watch changes.
  ///
  ///When the value in the [ActivationState] property is [ActivationState.notActivated], the URL in this directory is undefined and should not be used. When a session is active or inactive, the URL corresponds to the directory for the most recently paired Apple Watch. Even when the session becomes inactive, the URL remains valid so that you have time to update your data files before the final deactivation occurs.
  ///
  ///If the user uninstalls your app or unpairs their Apple Watch, iOS deletes this directory and its contents. If there is no paired watch, the value of this property is nil.
  final Uri? watchDirectoryURL;

  WatchOsPairedDeviceInfo(this.isPaired, this.isWatchAppInstalled,
      this.isComplicationEnabled, this.watchDirectoryURL);

  factory WatchOsPairedDeviceInfo.fromJson(Map<String, dynamic> json) =>
      WatchOsPairedDeviceInfo(
        json['isPaired'] as bool? ?? false,
        json['isWatchAppInstalled'] as bool? ?? false,
        json['isComplicationEnabled'] as bool? ?? false,
        urlToUri(json['watchDirectoryURL'] as String?),
      );
}
