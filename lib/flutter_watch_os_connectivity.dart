library flutter_watch_os_connectivity;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

import 'src/helpers/index.dart';
import 'src/models/index.dart';
import 'package:flutter_smart_watch_platform_interface/flutter_smart_watch_platform_interface.dart';

export 'src/helpers/index.dart' show ActivationState;

export 'src/models/index.dart'
    show
        ApplicationContext,
        WatchOsPairedDeviceInfo,
        UserInfoTransfer,
        FileTransfer,
        WatchOSMessage;

export 'package:flutter_smart_watch_platform_interface/helpers/index.dart'
    show Pair;

part 'watch_os_observer.dart';
part 'channel.dart';

class FlutterWatchOsConnectivity extends FlutterSmartWatchPlatformInterface {
  static registerWith() {
    FlutterSmartWatchPlatformInterface.instance = FlutterWatchOsConnectivity();
  }

  late WatchOSObserver _watchOSObserver;

  /// Check if your IOS device is supported to connect with WatchOS device
  @override
  Future<bool> isSupported() async {
    bool? isSupported = await channel.invokeMethod("isSupported");
    return isSupported ?? false;
  }

  /// Init and activate [WatchConnectivity] session
  Future configureAndActivateSession() async {
    _watchOSObserver = WatchOSObserver();
    _watchOSObserver.initAllStreamControllers();
    return channel.invokeMethod("configure");
  }

  /// Get current [ActivateState] of [WatchConnectivity] session
  Future<ActivationState> getActivateState() async {
    int stateIndex = await channel.invokeMethod("getActivateState");
    return ActivationState.values[stateIndex];
  }

  /// Get paired WatchOS device info
  Future<WatchOsPairedDeviceInfo> getPairedDeviceInfo() async {
    String jsonString = await channel.invokeMethod("getPairedDeviceInfo");
    Map<String, dynamic> json = jsonDecode(jsonString);
    return WatchOsPairedDeviceInfo.fromJson(json);
  }

  /// Check whether the WatchOS companion app is in the foreground
  /// If [getReachability] return true, the companion app is in the foreground, otherwise the companion app is in background or is teminated.
  Future<bool> getReachability() async {
    bool isReachable = await channel.invokeMethod("getReachability");
    return isReachable;
  }

  /// Send message to companion app, message can only be sent if [getReachability] is true
  Future<void> sendMessage(Map<String, dynamic> message,
      {MessageReplyHandler? replyHandler}) {
    String? handlerId;
    if (replyHandler != null) {
      handlerId = getRandomString(20);
      _watchOSObserver.replyHandlers[handlerId] = replyHandler;
    }
    return channel.invokeMethod("sendMessage", {
      "message": message,
      if (handlerId != null) "replyHandlerId": handlerId
    });
  }

  /// Return the current [ApplicationContext] context of session
  /// [ApplicationContext] is a map data which is synced across of IOS app and WatchOS app
  Future<ApplicationContext> getApplicationContext() async {
    Map rawContext = await channel.invokeMethod("getLatestApplicationContext");
    return ApplicationContext.fromJson(rawContext.toMapStringDynamic());
  }

  /// Update and sync the [ApplicationContext].
  /// [ApplicationContext] works like the common data between both WatchOS and IOS app,
  /// which can be updated by calling [updateApplicationContext] method and synced via [applicationContextUpdated].
  /// You can call this method either the WatchOS companion app is in background or foreground
  Future updateApplicationContext(Map<String, dynamic> applicationContext) {
    return channel.invokeMethod("updateApplicationContext", applicationContext);
  }

  /// Transfer user information.
  ///
  /// Returns [UserInfoTransfer] representing this transfer.
  ///
  /// You can cancel any transfer by calling [cancel] method of [UserInfoTransfer]
  Future<UserInfoTransfer?> transferUserInfo(Map<String, dynamic> userInfo,
      {bool isComplication = false}) async {
    userInfo["id"] = getRandomString(20);
    return channel.invokeMethod("transferUserInfo", {
      "userInfo": userInfo,
      "isComplication": isComplication
    }).then((rawUserInfoTransfer) {
      return _mapIdAndConvertUserInfoTransfer(
          (rawUserInfoTransfer as Map? ?? {}).toMapStringDynamic());
    });
  }

  UserInfoTransfer _mapIdAndConvertUserInfoTransfer(Map<String, dynamic> json) {
    Map<String, dynamic> userInfoInJson =
        (json["userInfo"] as Map? ?? {}).toMapStringDynamic();
    if (userInfoInJson.containsKey("id")) {
      json["id"] = (userInfoInJson["id"] ?? "").toString();
      (json["userInfo"] as Map).remove("id");
    }
    UserInfoTransfer userInfoTransfer = UserInfoTransfer.fromJson(json);
    userInfoTransfer.cancel = () =>
        channel.invokeMethod("cancelUserInfoTransfer", userInfoTransfer.id);
    return userInfoTransfer;
  }

  /// Retrieve pending user info transfers.
  ///
  /// Call this method to retrieve all on progress user info transfers.
  ///
  /// You can cancel any transfer by calling [cancel] method of [UserInfoTransfer]
  Future<List<UserInfoTransfer>> getInProgressUserInfoTransfers() {
    return channel
        .invokeMethod("getOnProgressUserInfoTransfers")
        .then((transfersJson) {
      return (transfersJson as List? ?? []).map((transferJson) {
        return _mapIdAndConvertUserInfoTransfer(
            transferJson.map<String, dynamic>(
                (key, value) => MapEntry(key.toString(), value)));
      }).toList();
    });
  }

  /// Retrieve remaining transfer count, use this method to determine that you should send a [Complication] user info data.
  Future<int> getRemainingComplicationUserInfoTransferCount() async {
    return channel
        .invokeMethod("getRemainingComplicationUserInfoTransferCount")
        .then((count) => count ?? 0);
  }

  ///Transfer a [File] to WatchOS companion app
  ///
  ///You can track the transfering progress implicitly with [onProgressChanged] handler.
  ///
  ///Return a [FileTransfer]
  Future<FileTransfer?> transferFileInfo(File file,
      {Map<String, dynamic> metadata = const {}}) async {
    Map<String, dynamic> mMetadata = Map<String, dynamic>.from(metadata);

    mMetadata["id"] = getRandomString(20);
    var rawFileTransferInMap = await channel.invokeMethod(
        "transferFileInfo", {"filePath": file.path, "metadata": mMetadata});
    if (rawFileTransferInMap != null && rawFileTransferInMap is Map) {
      Map<String, dynamic> fileTransferInJson =
          rawFileTransferInMap.toMapStringDynamic();
      return _mapIdAndConvertFileTransfer(fileTransferInJson);
    }
    return null;
  }

  /// Retrieve a [List] of on progress [FileTransfer]
  ///
  /// Use this method when you want to fetch pending [FileTransfer]s
  Future<List<FileTransfer>> getInProgressFileTransfers() {
    return channel
        .invokeMethod("getOnProgressFileTransfers")
        .then((transfersJson) {
      return (transfersJson as List? ?? []).map((transferJson) {
        return _mapIdAndConvertFileTransfer(transferJson.map<String, dynamic>(
            (key, value) => MapEntry(key.toString(), value)));
      }).toList();
    });
  }

  FileTransfer _mapIdAndConvertFileTransfer(Map<String, dynamic> json) {
    Map<String, dynamic> metadataInJson =
        (json["metadata"] as Map? ?? {}).toMapStringDynamic();
    json["id"] = metadataInJson["id"];
    metadataInJson.remove("id");
    FileTransfer fileTransfer = FileTransfer.fromJson(json);
    fileTransfer.cancel = () {
      fileTransfer.setOnProgressListener = (p0) {};
      return channel.invokeMethod("cancelFileTransfer", fileTransfer.id);
    };
    fileTransfer.setOnProgressListener = (onProgressChanged) {
      _watchOSObserver.progressHandlers[fileTransfer.id] = onProgressChanged;
      channel.invokeMethod("setFileTransferProgressListener", fileTransfer.id);
    };
    return fileTransfer;
  }

  Stream<ActivationState> get activationStateChanged =>
      _watchOSObserver.activateStateStreamController.stream;
  Stream<WatchOsPairedDeviceInfo> get pairedDeviceInfoChanged =>
      _watchOSObserver.pairedDeviceInfoStreamController.stream;
  Stream<WatchOSMessage> get messageReceived =>
      _watchOSObserver.messageStreamController.stream;
  Stream<bool> get reachabilityChanged =>
      _watchOSObserver.reachabilityStreamController.stream;
  Stream<ApplicationContext> get applicationContextUpdated =>
      _watchOSObserver.applicationContextStreamController.stream;
  Stream<Map<String, dynamic>> get userInfoReceived =>
      _watchOSObserver.userInfoStreamController.stream;
  Stream<List<UserInfoTransfer>> get pendingUserInfoTransferListChanged =>
      _watchOSObserver.onProgressUserInfoTransferListStreamController.stream;
  Stream<UserInfoTransfer> get userInfoTransferDidFinish =>
      _watchOSObserver.userInfoTransferFinishedStreamController.stream;
  Stream<Pair<File, Map<String, dynamic>?>> get fileReceived =>
      _watchOSObserver.fileInfoStreamController.stream;
  Stream<List<FileTransfer>> get pendingFileTransferListChanged =>
      _watchOSObserver.onProgressFileTransferListStreamController.stream;
  Stream<FileTransfer> get fileTransferDidFinish =>
      _watchOSObserver.fileTransferDidFinishStreamController.stream;

  @override
  void dispose() {
    _watchOSObserver.clearAllStreamControllers();
  }
}
