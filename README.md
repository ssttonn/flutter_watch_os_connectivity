# Flutter WatchOS Connectivity
[![Version](https://img.shields.io/pub/v/flutter_watch_os_connectivity?color=%23212121&label=Version&style=for-the-badge)](https://pub.dev/packages/flutter_watch_os_connectivity)
[![Publisher](https://img.shields.io/pub/publisher/flutter_watch_os_connectivity?color=E94560&style=for-the-badge)](https://pub.dev/publishers/sstonn.xyz)
[![Points](https://img.shields.io/pub/points/flutter_watch_os_connectivity?color=FF9F29&style=for-the-badge)](https://pub.dev/packages/flutter_watch_os_connectivity)
[![LINCENSE](https://img.shields.io/github/license/ssttonn/flutter_watch_os_connectivity?color=0F3460&style=for-the-badge)](https://github.com/ssttonn/flutter_smart_watch/blob/master/flutter_watch_os_connectivity/LICENSE)

<img src="https://www.apple.com/v/watchos/watchos-9/i/images/meta/watchos__f5mnt0zfc2i6_og.png?202210042233"/>

A plugin that provides a wrapper that enables Flutter apps to communicate with apps running on WatchOS.

> Note: I'd also written packages to communicate with WearOS devices, you can check it out right [here](https://pub.dev/packages/flutter_wear_os_connectivity).



## Table of contents
- [Screenshots](#screenshots)
- [Supported platforms](#supported_platforms)
- [Features](#main_features)
- [Getting started](#getting_started)
- [Configuration](#configuration)
    - [IOS](#ios_configuration)
- [How to use](#how_to_use)
    - [Get started](#get_started)
        - [Import the library](#get_started_1)
        - [Create new instance of `FlutterWatchOsConnectivity`](#get_started_2)
    - [Configuring and handling the activation state](#configuring_activation)
        - [Configure and activate `FlutterWatchOsConnectivity` session](#configuring_activation_1)
        - [Get current `ActivationState`](#configuring_activation_2)
        - [Listen to `ActivationState` changed](#configuring_activation_3)
    - [Getting paired device information and accessibility](#getting_paired_device_accessibility)
        - [Getting current paired device information](#getting_paired_device_accessibility_1)
        - [Listen to paired device information changed](#getting_paired_device_accessibility_2)
        - [Getting reachability of `WatchOsPairedDeviceInfo`](#getting_paired_device_accessibility_3)
        - [Listen `WatchOsPairedDeviceInfo` reachability state changed
        ](#getting_paired_device_accessibility_4)
    - [Sending and handling messages](#send_message)
        - [Send message](#send_message_1)
        - [Send message and wait for reply](#send_message_2)
        - [Receive messages](#send_message_3)
        - [Reply the message](#send_message_4)
    - [Obtaining and syncing `ApplicationContext`](#application_context)
        - [Obtaining an `ApplicationContext`](#application_context_1)
        - [Syncing an `ApplicationContext`](#application_context_2)
        - [Listen to `ApplicationContext` changed](#application_context_3)
    - [Transfering and handling user info with `UserInfoTransfer`](#transfer_user_info)
        - [Transfering user info](#transfer_user_info_1)
        - [Canceling an `UserInfoTransfer`](#transfer_user_info_2)
        - [Obtaining the number of complication transfers remaining](#transfer_user_info_3)
        - [Waiting for upcoming `UserInfoTransfer`s](#transfer_user_info_4)
        - [Obtaning a list of pending `UserInfoTransfer`](#transfer_user_info_5)
        - [Listen to pending `UserInfoTransfer` list changed](#transfer_user_info_6)
        - [Listen to the completion event of `UserInfoTransfer`](#transfer_user_info_7)
    - [Transfering and handling `File` with `FileTransfer`](#transfer_file)
        - [Transfering file](#transfer_file_1)
        - [Obtaning current on progress `UserInfoTransfer` list](#transfer_file_2)
        - [Canceling a `FileTransfer`](#transfer_file_3)
        - [Obtaning a list of pending `FileTransfer`](#transfer_file_4)
        - [Listen to pending `FileTransfer` list changed](#transfer_file_5)
        - [Waiting for upcoming `FileTransfer`s](#transfer_file_6)
        - [Listen to the completion event of `FileTransfer`](#transfer_file_7)

## Screenshots <a name="screenshots"/>

## Supported platforms <a name="supported_platforms"></a>
- iOS

## Features <a name="main_features"></a>
Use this plugin in your Flutter app to:
- Communicate with WatchOS application. 
- Send message.
- Update application context.
- Send user info data.
- Transfer files.
- Check for wearable device info.
- Detect wearable reachability.

## Getting started <a name="getting_started"/>
For WatchOS companion app, this plugin uses [Watch Connectivity](https://developer.apple.com/documentation/watchconnectivity) framework under the hood to communicate with IOS app.

## Configuration <a name="configuration"/>

### IOS <a name="ios_configuration"/>

1. Create an WatchOS companion app, you can follow this [instruction](https://developer.apple.com/tutorials/swiftui/creating-a-watchos-app) to create new WatchOS app.

> Note: If you've created a WatchOS app with UIKit, the WatchOS companion app must have Bundle ID with the following format in order to communicate with IOS app: YOUR_IOS_BUNDLE_ID.watchkitapp.

That's all, you're ready to communicate with WatchOS app now.

## How to use <a name="how_to_use"/>
### Get started <a name="get_started"/>
#### Import the library <a name="get_started_1"/>

```dart
import 'package:flutter_watch_os_connectivity/flutter_watch_os_connectivity.dart';
```

#### Create new instance of `FlutterWatchOsConnectivity` <a name="get_started_2"/>

```dart
FlutterWatchOsConnectivity _flutterWatchOsConnectivity = FlutterWatchOsConnectivity();
```
---
### Configuring and handling the activation state <a name="configuring_activation"/>

`ActivationState` tells us about the current `FlutterWatchOsConnectivity` session activation state. You can read more detail about it [here](https://developer.apple.com/documentation/watchconnectivity/wcsession).

Each IOS device can only pair with one WatchOS device at the same time, so you need to monitor on `ActivationState` and have a suitable solution for each case.

<img src="https://docs-assets.developer.apple.com/published/ee5ac6b8c3/session_activation_flow_2x_78d01144-a11d-4d5a-b8b8-6eed63f0f1c7.png" alt="MarineGEO circle logo" />

There are 3 states of `ActivationState`:

- Activated 

The session is active and the Watch app and iOS app may communicate with each other freely.

- Not activated 

The session is not activated. When in this state, no communication occurs between the Watch app and iOS app. It is a programmer error to try to send data to the counterpart app while in this state.

- Inactive

The session was active but is transitioning to the deactivated state. The session’s delegate object may still receive data while in this state, but it is a programmer error to try to send data to the counterpart app.

#### Configure and activate `FlutterWatchOsConnectivity` session <a name="configuring_activation_1"/>

> NOTE: Your cannot send or receive messages until you call `configureAndActivateSession()` method.

```dart
_flutterWatchOsConnectivity.configureAndActivateSession();
```

#### Get current `ActivationState` <a name="configuring_activation_2"/>

> NOTE: You can only interact with some methods of `FlutterWatchOsConnectivity` plugin if your `ActivationState` is `activated`

```dart
ActivationState _currentState = await _flutterWatchOsConnectivity.getActivateState();
if (_currentState == ActivationState.activated) {
    // Continue to use the plugin
}else{
    // Do something in this case
}
```

#### Listen to `ActivationState` changed <a name="configuring_activation_3"/>

> NOTE: You can only interact with some methods of `FlutterWatchOsConnectivity` plugin if your `ActivationState` is `activated`

```dart
_flutterWatchOsConnectivity.activationStateChanged.listen((activationState) {
if (activationState == ActivationState.activated) {
    // Continue to use the plugin
}else{
    // Do something in this case
}});
```
---
### Getting paired device information and reachability <a name="getting_paired_device_accessibility"/>
Each IOS device can only pair with one WatchOS device at the same time, so the `WatchOsPairedDeviceInfo` object retrieved from `FlutterWatchOsConnectivity` is unique for each device.

Users can disconnect and reconnect various WatchOS devices to their IOS phones, so you should keep track on `WatchOsPairedDeviceInfo`.

`WatchOSPairedDeviceInfo` has following properties:
- `isPaired`

The value of this property is true when the iPhone is paired to an Apple Watch or false when it is not.

- `isWatchAppInstalled`

The user can choose to install only a subset of available apps on Apple Watch. The value of this property is true when the Watch app associated with the current iOS app is installed on the user’s Apple Watch or false when it is not installed.

- `isComplicationEnabled`

The value of this property is true when the app’s complication is installed on the active clock face. When the value of this property is false, calls to the `transferUserInfo(userInfo: userInfo, isComplication: true)` method fail immediately.

- `watchDirectoryURL`

You must activate the current session before accessing this URL. Use this directory to store preferences, files, and other data that is relevant to the specific instance of your Watch app running on the currently paired Apple Watch. If more than one Apple Watch is paired with the same iPhone, the URL in this directory changes when the active Apple Watch changes.

When the value in the activationState property is WCSessionActivationState.notActivated, the URL in this directory is undefined and should not be used. When a session is active or inactive, the URL corresponds to the directory for the most recently paired Apple Watch. Even when the session becomes inactive, the URL remains valid so that you have time to update your data files before the final deactivation occurs.

If the user uninstalls your app or unpairs their Apple Watch, iOS deletes this directory and its contents. If there is no paired watch, the value of this property is nil.

#### Getting current paired device information <a name="getting_paired_device_accessibility_1"/>
```dart
WatchOsPairedDeviceInfo _pairedDeviceInfo = await _flutterWatchOsConnectivity.getPairedDeviceInfo();
```

#### Listen to paired device information changed <a name="getting_paired_device_accessibility_2"/>
```dart
_flutterWatchOsConnectivity.pairedDeviceInfoChanged.listen((info) {
    _pairedDeviceInfo = info;
});
```

#### Getting reachability of `WatchOsPairedDeviceInfo` <a name="getting_paired_device_accessibility_3"/>
```dart
bool _isReachable = await _flutterWatchOsConnectivity.getReachability();
```

This property is true when the WatchKit extension and the iOS app can communicate with each other.

Specifically: 

- WatchKit extension: The iOS device is within range, so communication can occur and the WatchKit extension is running in the foreground, or is running with a high priority in the background (for example, during a workout session or when a complication is loading its initial timeline data).

- iOS app: A paired and active Apple Watch is in range, the corresponding WatchKit extension is running, and the WatchKit extension’s isReachable property is true.

In all other cases, the value is false.

#### Listen `WatchOsPairedDeviceInfo` reachability state changed <a name="getting_paired_device_accessibility_4"/>
```dart
_flutterWatchOsConnectivity.reachabilityChanged.listen((isReachable) {
    _isReachable = isReachable;
});
```
---
### Sending and handling messages <a name="send_message"/>
IOS apps can send message data to WatchOS apps.
> Note: Messages can only be sent if both apps are reachable, see [Getting paired device information and reachability](#getting_paired_device_accessibility) for more details.

Each message received will be constructed using the `WatchOsMessage` object.

`WatchOsMessage` will have following properties:
- `data`

A `Map<String, dynamic>` represented for each message map data.

The following data value types are supported:

`null` | `bool` | `int` | `double` | `String`	| `Uint8List` | `Int32List` | `Int64List` | `Float32List` | `Float64List` | `List` | `Map`

- `relyMessage` 

A optional callback method to indicate whether this message is waiting for reply. 

#### Send message <a name="send_message_1"/>
You can construct a message map by passing a `Map<String, dynamic>` into `sendMessage` method
```dart
await _flutterWatchOsConnectivity.sendMessage({
    "message": "This is a message sent from IOS app at ${DateTime.now().millisecondsSinceEpoch}"
});
```

#### Send message and wait for reply <a name="send_message_2"/>
You can also wait for a reply from WatchOS apps by specify a `replyHandler`

```dart
_flutterWatchOsConnectivity.sendMessage({
    "message": "This is a message sent from IOS app with reply handler at ${DateTime.now().millisecondsSinceEpoch}"
}, replyHandler: ((message) async {
    // After watchOS received and replied to your message, this callback will be triggered
    _currentRepliedMessage = message;
}));
```

#### Receive messages <a name="send_message_3"/>
You can listen to upcoming message sent by WatchOS apps 

```dart
_flutterWatchOsConnectivity.messageReceived.listen((message) async {    
    /// New message is received, you can read it data map
    _currentMessage = message.data;
});
```

#### Reply the message <a name="send_message_4"/>
If the `replyMessage` property of received `WatchOsMessage` object is not `null`. You should reply to that `WatchOsMessage`.

```dart
_flutterWatchOsConnectivity.messageReceived.listen((message) async {    
    /// New message is received, you can read it data map
    _currentMessage = message.data;
    
    /// Check if this message is needed to reply
    if (message.onReply != null) {
        /// If so, reply to this message
        try {
          await message.replyMessage!({
            "message":
                "Message received on IOS app at ${DateTime.now().millisecondsSinceEpoch}"
          });
        } catch (e) {
          print(e);
        }
    }
});
```
Sending and receiving messages are great ways to communicate with the WatchOS app, but they have one limitation:
- They can only work if both IOS and WatchOS device are reachable which mean they can only work if both apps are in foreground only.

So to be able to communicate in the background, we have 2 alternative solutions: [Obtaining and syncing `ApplicationContext`](#application_context) and [Transfering and handling user info with `UserInfoTransfer`](transfer_user_info)

---
### Obtaining and syncing `ApplicationContext` <a name="application_context"/>
`ApplicationContext` can be defined as a shared data between iOS and WatchOS applications and can be obtained and updated on both sides.
The `ApplicationContext`'s data will be synchronized and retained as long as the connection between the iOS app and the WatchOS app persists.

`ApplicationContext` contains following properties:
- `currentData`

A `Map<String, dynamic>` represents the current application context on this respective application.

The following data value types are supported:

`null` | `bool` | `int` | `double` | `String`	| `Uint8List` | `Int32List` | `Int64List` | `Float32List` | `Float64List` | `List` | `Map`

- `receivedData`

A `Map<String, dynamic>` represents the received application context on this respective application.

The following data value types are supported:

`null` | `bool` | `int` | `double` | `String`	| `Uint8List` | `Int32List` | `Int64List` | `Float32List` | `Float64List` | `List` | `Map`

#### Obtaining an `ApplicationContext` <a name="application_context_1"/>
```dart
ApplicationContext _applicationContext = await _flutterWatchOsConnectivity.getApplicationContext();
```

#### Syncing an `ApplicationContext` <a name="application_context_2"/>
Call `updateApplicationContext` method on iOS app to cope new data to `currentData` on iOS app and to `receivedData` on WatchOS app.

To make it easy to understand:

- `currentData` on iOS app and `receivedData` on WatchOS are same. 
- `receivedData` on iOS app and `currentData` on WatchOS are same.

So if you call this method to sync `ApplicationContext`'s `currentData` on the iOS application, WatchOS application will received it as `receivedData`.

```dart
_flutterWatchOsConnectivity.updateApplicationContext({
    "message": "Application Context updated by IOS app at ${DateTime.now().millisecondsSinceEpoch}"
});
```

#### Listen to `ApplicationContext` changed <a name="application_context_3"/>
`ApplicationContext` can be observed by listen to `applicationContextUpdated` stream.

```dart
_flutterWatchOsConnectivity.applicationContextUpdated.listen((context) {
    _applicationContext = context;
});
```

---
### Transfering and handling user info with `UserInfoTransfer` <a name="transfer_user_info"/>
As an alternative solution for [Send and handling messages](#send_message), we can transfer a `Map<String, dynamic>` to counterpart app with the following advantages:
- `UserInfoTransfer` is transferred on a transaction-by-transaction basis.
- Each `UserInfoTransfer` can be transferred even if the iOS or WatchOS is not in foreground.
- `UserInfoTransfer` can be cancelled.

An `UserInfoTransfer` has following properties:

- `id`

A `String` used to uniquely identify the `UserInfoTransfer`.

- `isCurrentComplicationInfo`

A `bool` indicating whether the data is related to the app’s complication, for more info about WatchOS's complications, please check this [link](https://developer.apple.com/documentation/clockkit/creating_complications_for_your_watchos_app).

- `userInfo`

The `Map<String, dynamic>` data being transferred.

- `isTransfering`

A `bool` indicating whether the data is being tranfered.

- `cancel`

A method used to cancel the `UserInfoTransfer`
 
#### Transfering user info <a name="transfer_user_info_1"/>
Call `transferUserInfo` method when you want to send a `Map<String, dynamic>` to the counterpart and ensure that it’s delivered. `Map<String, dynamic>` sent using this method are queued on the other device and delivered in the order in which they were sent. After a transfer begins, the transfer operation continues even if the app is suspended.

```dart
UserInfoTransfer? _userInfoTransfer = await _flutterWatchOsConnectivity.transferUserInfo({
    "message": "User info sent by IOS app at ${DateTime.now().millisecondsSinceEpoch}"
});
```

You can also transfer a user info as `Complication`

Call this method when you have new data to send to your complication. Your WatchKit extension can use the data to replace or extend its current timeline entries.

> Note: Make sure you [Obtaining the number of complication transfers remaining](#transfer_user_info_3) before calling this method, otherwise, `UserInfoTransfer` will be treated as non-complication. About complication, please check this [link](https://developer.apple.com/documentation/clockkit/creating_complications_for_your_watchos_app).

```dart
UserInfoTransfer? _userInfoTransfer = await _flutterWatchOsConnectivity.transferUserInfo({
    "message": "User info sent by IOS app at ${DateTime.now().millisecondsSinceEpoch}"
}, isComplication: true);
```

#### Canceling an `UserInfoTransfer` <a name="transfer_user_info_2"/>
Call this method on an `UserInfoTransfer` with `isTransfering` flag is `true` to cancel the transfer.

```dart
await _userInfoTransfer.cancel()
```

#### Obtaining the number of complication transfers remaining <a name="transfer_user_info_3"/>
> Note: This is the number of remaining times that you can call `transferUserInfo(isComplication: true)` method during the current day. If this property is set to 0, any additional calls to `transferUserInfo(isComplication: true)` method use `transferUserInfo(isComplication: false)` instead. About WatchOS complication, please check this [link](https://developer.apple.com/documentation/clockkit/creating_complications_for_your_watchos_app).

```dart
int remainingComplicationCount = await _flutterWatchOsConnectivity.getRemainingComplicationUserInfoTransferCount();
```

#### Waiting for upcoming `UserInfoTransfer`s <a name="transfer_user_info_4"/>
You can wait for user info `Map` to be sent through this stream.

```dart
_flutterWatchOsConnectivity.userInfoReceived.listen((userInfo) {
    _receivedUserInfo = userInfo;
    print(_receivedUserInfo is Map<String, dynamic>) /// true
});
```

#### Obtaning a list of pending `UserInfoTransfer` <a name="transfer_user_info_5"/>
In progress `UserInfoTransfer` can be retrieved via this method.

```dart
List<UserInfoTransfer> _pendingTransfers = await _flutterWatchOsConnectivity.getInProgressUserInfoTransfers()
```

#### Listen to pending `UserInfoTransfer` list changed <a name="transfer_user_info_6"/>
You can also observe change events in the pending `UserInfoTransfer` list.

```dart
_flutterWatchOsConnectivity.pendingUserInfoTransferListChanged.listen((transfers) {
    _userInfoPendingTransfers = transfers;
});
```

#### Listen to the completion event of `UserInfoTransfer` <a name="transfer_user_info_7"/>

This stream will emit corresponding `UserInfoTransfer` object when any `UserInfoTransfer` is completed.

```dart
_flutterWatchOsConnectivity.userInfoTransferDidFinish.listen((transfer) {
    inspect(transfer);
});
```

---
### Transfering and handling `File` with `FileTransfer` <a name="transfer_file"/>
Like [Transfering and handling user info with `UserInfoTransfer`](#transfer_user_info), you can also transfer a single `File` using `FileTransfer` with same avantages.

`FileTransfer` object contains the following properties:
- `id`

A `String` used to uniquely identify the `FileTransfer`.

- `file`

The `File` being transferred.

- `metadata`

The optional`Map<String, dynamic>` for additional payload data.

- `isTransfering`

A `bool` indicating whether the `File` is being tranfered.

- `cancel`

A method used to cancel the `FileTransfer`

> Note: The duration of the transfer will depend on the size of the file, the larger the size, the longer the transfer will take.

#### Transfering file <a name="transfer_file_1"/>
Pass a `File` into `transferFile` method, you can either pass an addtional payload data called `metadata` or not.

```dart
import 'package:image_picker/image_picker.dart';
import 'dart:io';

XFile? _file = await ImagePicker().pickImage(source: ImageSource.gallery);
if (_file != null) {
    FileTransfer? _fileTransfer = await _flutterWatchOsConnectivity.transferFile(File(_file.path), metadata: {
        "message": "File transfered by IOS app at ${DateTime.now().millisecondsSinceEpoch}"
    });
}
```

#### Obtaning current on progress `UserInfoTransfer` list <a name="transfer_file_2"/>
You can observe the current `FileTransfer` progress by calling a callback method on `FileTransfer` instance

```dart
if (_fileTransfer?.setOnProgressListener != null)
    _fileTransfer?.setOnProgressListener(((progress) {
            print("${_fileTransfer.id}: ${progress.currentProgress}");
}));
```

#### Canceling a `FileTransfer` <a name="transfer_file_3"/>
Call this method on an `FileTransfer` with `isTransfering` flag is `true` to cancel the transfer.

```dart
await _userInfoTransfer.cancel()
```

#### Obtaning a list of pending `FileTransfer` <a name="transfer_file_4"/>
In progress `FileTransfer` can be retrieved via this method.

```dart
List<FileTransfer> _pendingTransfers = await _flutterWatchOsConnectivity.getInProgressFileTransfers()
```

#### Listen to pending `FileTransfer` list changed <a name="transfer_file_5"/>
You can also observe change events in the pending `FileTransfer` list.

```dart
_flutterWatchOsConnectivity.pendingFileTransferListChanged
        .listen((transfers) {
    _filePendingTransfers = transfers;
});
```

#### Waiting for upcoming `FileTransfer`s <a name="transfer_file_6"/>
You can wait for file data to be sent through this stream.

File data is a `Pair<File, Map<String, dynamic>?>`:

- The `File` can be retrieved via `pair.left`
- The `Metadata` can be retrieved via `pair.right`


```dart
_flutterWatchOsConnectivity.fileReceived.listen((pair) {
    _receivedFileDataPair = pair;
});
```

#### Listen to the completion event of `FileTransfer` <a name="transfer_file_7"/>

This stream will emit corresponding `FileTransfer` object when any `FileTransfer` is completed.

```dart
_flutterWatchOsConnectivity.fileTransferDidFinish.listen((transfer) {
      inspect(transfer);
});
```
---
For more details, please check out my [Flutter example project](https://github.com/ssttonn/flutter_smart_watch/tree/master/flutter_watch_os_connectivity/example) and [WatchOS example project](https://github.com/ssttonn/flutter_smart_watch/tree/master/flutter_watch_os_connectivity/example/ios/TestWatchOS).




