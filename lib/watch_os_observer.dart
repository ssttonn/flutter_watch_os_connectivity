part of flutter_watch_os_connectivity;

class WatchOSObserver {
  late StreamController<ActivationState> activateStateStreamController;
  late StreamController<WatchOsPairedDeviceInfo>
      pairedDeviceInfoStreamController;
  late StreamController<WatchOSMessage> messageStreamController;
  late StreamController<bool> reachabilityStreamController;
  late StreamController<ApplicationContext> applicationContextStreamController;
  late StreamController<Map<String, dynamic>> userInfoStreamController;
  late StreamController<List<UserInfoTransfer>>
      onProgressUserInfoTransferListStreamController;
  late StreamController<UserInfoTransfer>
      userInfoTransferFinishedStreamController;
  late StreamController<Pair<File, Map<String, dynamic>?>>
      fileInfoStreamController;
  late StreamController<List<FileTransfer>>
      onProgressFileTransferListStreamController;
  late StreamController<FileTransfer> fileTransferDidFinishStreamController;
  late Map<String, MessageReplyHandler> replyHandlers;
  late Map<String, ProgressHandler> progressHandlers;

  WatchOSObserver() {
    callbackChannel.setMethodCallHandler(_methodCallhandler);
  }

  Future _methodCallhandler(MethodCall call) async {
    switch (call.method) {
      case "activateStateChanged":
        //* Check for activateStateIndex argument, if it's null, use 0 ~ ActivationState.notActivated
        int activateStateIndex = call.arguments as int? ?? 0;
        activateStateStreamController
            .add(ActivationState.values[activateStateIndex]);
        break;
      case "pairDeviceInfoChanged":
        Map<String, dynamic> rawPairedDeviceInfoJson =
            (call.arguments as Map? ?? {}).toMapStringDynamic();
        if (rawPairedDeviceInfoJson["error"] != null) {
          ///* Emit error and return
          pairedDeviceInfoStreamController
              .addError(Exception(rawPairedDeviceInfoJson["error"]));
          return;
        }
        try {
          ///* Map raw map to [PairedDeviceInfo] object
          WatchOsPairedDeviceInfo pairedDeviceInfo =
              WatchOsPairedDeviceInfo.fromJson(rawPairedDeviceInfoJson);
          pairedDeviceInfoStreamController.add(pairedDeviceInfo);
        } catch (e) {
          pairedDeviceInfoStreamController.addError(e);
        }
        break;
      case "messageReceived":
        Map<String, dynamic> messageDataMap =
            (call.arguments as Map? ?? {}).toMapStringDynamic();
        try {
          Map<String, dynamic> messageData =
              (messageDataMap["message"] as Map? ?? {}).toMapStringDynamic();
          String? replyHandlerId = call.arguments["replyHandlerId"];
          WatchOSMessage message = WatchOSMessage(
              data: messageData,
              //* Reply callback
              replyMessage: ((message) {
                return channel.invokeMethod("replyMessage", {
                  "replyMessage": message,
                  "replyHandlerId": replyHandlerId
                });
              }));
          messageStreamController.add(message);
        } catch (e) {
          messageStreamController.addError(e);
        }
        break;
      case "reachabilityChanged":
        bool isReachable = call.arguments as bool? ?? false;
        //* Emit reachble event
        reachabilityStreamController.add(isReachable);
        break;
      case "onMessageReplied":
        var arguments = call.arguments;
        if (arguments != null) {
          Map? replyMessage = arguments["replyMessage"] as Map?;
          String? replyMessageId = arguments["replyHandlerId"] as String?;
          if (replyMessage != null && replyMessageId != null) {
            replyHandlers[replyMessageId]?.call(replyMessage
                .map((key, value) => MapEntry(key.toString(), value)));
            replyHandlers.remove(replyMessageId);
          }
        }
        break;
      case "onApplicationContextUpdated":
        var arguments = call.arguments;
        if (arguments != null && arguments is Map) {
          var applicationContext = ApplicationContext.fromJson(
              arguments.map((key, value) => MapEntry(key.toString(), value)));
          applicationContextStreamController.add(applicationContext);
        }
        break;
      case "onUserInfoReceived":
        var arguments = call.arguments;
        if (arguments != null && arguments is Map) {
          var userInfo =
              arguments.map((key, value) => MapEntry(key.toString(), value));
          userInfoStreamController.add(userInfo);
        }
        break;
      case "onPendingUserInfoTransferListChanged":
        var arguments = call.arguments;
        if (arguments != null &&
            arguments is List &&
            arguments.every((transfer) => transfer is Map)) {
          List<UserInfoTransfer> transfers = arguments.map((transferJson) {
            return _mapIdAndConvertUserInfoTransfer((transferJson as Map)
                .map((key, value) => MapEntry(key.toString(), value)));
          }).toList();
          onProgressUserInfoTransferListStreamController.add(transfers);
        }
        break;
      case "onUserInfoTransferDidFinish":
        Map<String, dynamic> rawUserInfoTransferJson =
            (call.arguments as Map? ?? {}).toMapStringDynamic();
        if (rawUserInfoTransferJson["error"] != null) {
          //* Emit error and return
          userInfoTransferFinishedStreamController
              .addError(Exception(rawUserInfoTransferJson["error"]));
          return;
        }
        try {
          //* Convert raw map to [UserInfoTransfer]
          UserInfoTransfer userInfoTransfer =
              _mapIdAndConvertUserInfoTransfer(rawUserInfoTransferJson);
          userInfoTransferFinishedStreamController.add(userInfoTransfer);
        } catch (e) {
          //* Emit error and return
          userInfoTransferFinishedStreamController.addError(e);
        }
        break;
      case "onFileReceived":
        Map<String, dynamic> rawFileJson =
            (call.arguments as Map? ?? {}).toMapStringDynamic();

        if (rawFileJson["error"] != null) {
          //* Emit error and return
          fileInfoStreamController.addError(Exception(rawFileJson["error"]));
          return;
        }

        ///* Check if file path is not null
        if (rawFileJson["path"] != null) {
          //* get received file from path
          var receivedFile = File(rawFileJson["path"]);

          // * add received file to global stream
          fileInfoStreamController
              .add(Pair(right: rawFileJson["metadata"], left: receivedFile));
        }
        break;
      case "onPendingFileTransferListChanged":
        var arguments = call.arguments;
        if (arguments != null &&
            arguments is List &&
            arguments.every((transfer) => transfer is Map)) {
          List<FileTransfer> transfers = arguments.map((transferJson) {
            return _mapIdAndConvertFileTransfer((transferJson as Map)
                .map((key, value) => MapEntry(key.toString(), value)));
          }).toList();
          onProgressFileTransferListStreamController.add(transfers);
        }
        break;
      case "onFileTransferDidFinish":
        Map<String, dynamic> arguments = (call.arguments as Map? ?? {})
            .map((key, value) => MapEntry(key.toString(), value));
        if (arguments["error"] != null) {
          //* Emit error and return
          fileTransferDidFinishStreamController
              .addError(Exception(arguments["error"]));
          return;
        }
        try {
          //* Convert raw map to [FileTransfer] object
          FileTransfer fileTransfer = _mapIdAndConvertFileTransfer(
              arguments.map((key, value) => MapEntry(key.toString(), value)));
          fileTransferDidFinishStreamController.add(fileTransfer);
        } catch (e) {
          fileTransferDidFinishStreamController.addError(e);
        }
        break;
      case "onFileProgressChanged":
        Map<String, dynamic> arguments = (call.arguments as Map? ?? {})
            .map((key, value) => MapEntry(key.toString(), value));
        if (arguments["transferId"] != null) {
          Progress progress = Progress.fromJson(
              (arguments["progress"] as Map? ?? {})
                  .map((key, value) => MapEntry(key.toString(), value)));
          progressHandlers[arguments["transferId"]]?.call(progress);
        }
        break;
    }
  }

  UserInfoTransfer _mapIdAndConvertUserInfoTransfer(Map<String, dynamic> json) {
    if (json.containsKey("userInfo") && json["userInfo"] is Map) {
      Map<String, dynamic> userInfoInJson = (json["userInfo"] as Map)
          .map((key, value) => MapEntry(key.toString(), value));
      if (userInfoInJson.containsKey("id")) {
        json["id"] = (userInfoInJson["id"] ?? "").toString();
        (json["userInfo"] as Map).remove("id");
      }
    }
    UserInfoTransfer userInfoTransfer = UserInfoTransfer.fromJson(json);
    userInfoTransfer.cancel = () =>
        channel.invokeMethod("cancelUserInfoTransfer", userInfoTransfer.id);
    return userInfoTransfer;
  }

  FileTransfer _mapIdAndConvertFileTransfer(Map<String, dynamic> json) {
    if (json.containsKey("metadata") && json["metadata"] is Map) {
      Map<String, dynamic> metadataInJson = (json["metadata"] as Map)
          .map((key, value) => MapEntry(key.toString(), value));
      json["id"] = metadataInJson["id"];
      metadataInJson.remove("id");
    }
    FileTransfer fileTransfer = FileTransfer.fromJson(json);
    fileTransfer.cancel =
        () => channel.invokeMethod("cancelFileTransfer", fileTransfer.id);
    fileTransfer.setOnProgressListener = (onProgressChanged) {
      progressHandlers[fileTransfer.id] = onProgressChanged;
      channel.invokeMethod("setFileTransferProgressListener", fileTransfer.id);
    };
    return fileTransfer;
  }

  initAllStreamControllers() {
    activateStateStreamController = StreamController.broadcast();
    pairedDeviceInfoStreamController = StreamController.broadcast();
    messageStreamController = StreamController.broadcast();
    reachabilityStreamController = StreamController.broadcast();
    applicationContextStreamController = StreamController.broadcast();
    userInfoStreamController = StreamController.broadcast();
    onProgressUserInfoTransferListStreamController =
        StreamController.broadcast();
    userInfoTransferFinishedStreamController = StreamController.broadcast();
    fileInfoStreamController = StreamController.broadcast();
    onProgressFileTransferListStreamController = StreamController.broadcast();
    fileTransferDidFinishStreamController = StreamController.broadcast();
    replyHandlers = {};
    progressHandlers = {};
  }

  clearAllStreamControllers() {
    activateStateStreamController.close();
    pairedDeviceInfoStreamController.close();
    messageStreamController.close();
    reachabilityStreamController.close();
    applicationContextStreamController.close();
    userInfoStreamController.close();
    userInfoTransferFinishedStreamController.close();
    onProgressUserInfoTransferListStreamController.close();
    fileInfoStreamController.close();
    onProgressFileTransferListStreamController.close();
    fileTransferDidFinishStreamController.close();
    replyHandlers.clear();
    progressHandlers.clear();
  }
}
