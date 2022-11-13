import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'widgets/spacing_column.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_watch_os_connectivity/flutter_watch_os_connectivity.dart';

class MyIOSApp extends StatefulWidget {
  const MyIOSApp({Key? key}) : super(key: key);

  @override
  State<MyIOSApp> createState() => _MyIOSAppState();
}

class _MyIOSAppState extends State<MyIOSApp> {
  FlutterWatchOsConnectivity _flutterWatchOsConnectivity =
      FlutterWatchOsConnectivity();
  bool _isReachable = false;
  WatchOsPairedDeviceInfo _pairedDeviceInfo =
      WatchOsPairedDeviceInfo(false, false, false, Uri());

  Map<String, dynamic> _currentMessage = new Map();
  Map<String, dynamic> _currentRepliedMessage = new Map();

  ApplicationContext _applicationContext = ApplicationContext({}, {});

  Map<String, dynamic> _receivedUserInfo = new Map();
  List<UserInfoTransfer> _userInfoPendingTransfers = [];

  Pair<File, Map<String, dynamic>?>? _receivedFileData;
  List<FileTransfer> _pendingFileTransfers = [];

  ActivationState _activationState = ActivationState.notActivated;

  @override
  void initState() {
    super.initState();
    _flutterWatchOsConnectivity.configureAndActivateSession();
    _flutterWatchOsConnectivity.activationStateChanged
        .listen((activationState) {
      if (activationState == ActivationState.activated) {
        _flutterWatchOsConnectivity.pairedDeviceInfoChanged.listen((info) {
          setState(() {
            _pairedDeviceInfo = info;
          });
        });
        _flutterWatchOsConnectivity.getPairedDeviceInfo().then((info) {
          setState(() {
            _pairedDeviceInfo = info;
          });
        });
      }
      setState(() {
        _activationState = activationState;
      });
    });
    _flutterWatchOsConnectivity.pairedDeviceInfoChanged.listen((info) {
      setState(() {
        _pairedDeviceInfo = info;
      });
    });
    _flutterWatchOsConnectivity.reachabilityChanged.listen((isReachable) {
      setState(() {
        _isReachable = isReachable;
      });
    });

    _flutterWatchOsConnectivity.messageReceived.listen((message) async {
      setState(() {
        _currentMessage = message.data;
      });
      if (message.replyMessage != null) {
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
    _flutterWatchOsConnectivity.applicationContextUpdated.listen((context) {
      setState(() {
        _applicationContext = context;
      });
    });

    _flutterWatchOsConnectivity.userInfoReceived.listen((userInfo) {
      setState(() {
        _receivedUserInfo = userInfo;
      });
    });

    _flutterWatchOsConnectivity
        .getInProgressUserInfoTransfers()
        .then((transfers) {
      setState(() {
        _userInfoPendingTransfers = transfers;
      });
    });
    _flutterWatchOsConnectivity.pendingUserInfoTransferListChanged
        .listen((transfers) {
      setState(() {
        _userInfoPendingTransfers = transfers;
      });
    });
    _flutterWatchOsConnectivity.userInfoTransferDidFinish.listen((transfer) {
      inspect(transfer);
    });

    _flutterWatchOsConnectivity.fileReceived.listen((pair) {
      setState(() {
        _receivedFileData = pair;
      });
    });
    _flutterWatchOsConnectivity.getInProgressFileTransfers().then((transfers) {
      setState(() {
        _pendingFileTransfers = transfers;
        _pendingFileTransfers.forEach((transfer) {
          transfer.setOnProgressListener((progress) {
            print("${transfer.id}: ${progress.currentProgress}");
          });
        });
      });
    });
    _flutterWatchOsConnectivity.pendingFileTransferListChanged
        .listen((transfers) {
      setState(() {
        _pendingFileTransfers = transfers;
        _pendingFileTransfers.forEach((transfer) {
          transfer.setOnProgressListener((progress) {
            print("${transfer.id}: ${progress.currentProgress}");
          });
        });
      });
    });
    _flutterWatchOsConnectivity.fileTransferDidFinish.listen((transfer) {
      inspect(transfer);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _flutterWatchOsConnectivity.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: SingleChildScrollView(
          physics:
              AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: SpacingColumn(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _pairedDeviceInfoSection(theme),
              _sendMessageSection(theme),
              _updateApplicationContextSession(theme),
              _sendUserInfoSession(theme),
              _transferFileSession(theme),
            ],
          ),
        ),
      ),
    );
  }

  _pairedDeviceInfoSection(ThemeData theme) {
    return _section(theme,
        child: SpacingColumn(
          spacing: 5,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("ActivationState: ",
                style: theme.textTheme.headline6?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary)),
            Text("${_activationState}"),
            Text("isReachable: ",
                style: theme.textTheme.headline6?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary)),
            Text("${_isReachable}",
                style: theme.textTheme.subtitle2?.copyWith(
                    color:
                        _isReachable ? Colors.greenAccent : Colors.redAccent)),
            Text("isPaired: ",
                style: theme.textTheme.headline6?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary)),
            Text("${_pairedDeviceInfo.isPaired}"),
            Text("isWatchAppInstalled: ",
                style: theme.textTheme.headline6?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary)),
            Text("${_pairedDeviceInfo.isWatchAppInstalled}"),
            Text("isComplicationEnabled: ",
                style: theme.textTheme.headline6?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary)),
            Text("${_pairedDeviceInfo.isComplicationEnabled}"),
            Text("watchDirectoryURL: ",
                style: theme.textTheme.headline6?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary)),
            Text("${_pairedDeviceInfo.watchDirectoryURL?.path}")
          ],
        ));
  }

  _sendMessageSection(ThemeData theme) {
    return _section(theme,
        child: SpacingColumn(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10,
          children: [
            Text("Message received: ",
                style: theme.textTheme.headline6?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary)),
            Text(_currentMessage.toString()),
            Text("Reply received: ",
                style: theme.textTheme.headline6?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary)),
            Text(_currentRepliedMessage.toString()),
            _button(theme, title: "Send Message", onPressed: () {
              if (_isReachable) {
                _flutterWatchOsConnectivity.sendMessage({
                  "message":
                      "This is a message sent from IOS app at ${DateTime.now().millisecondsSinceEpoch}"
                });
              }
            }),
            _button(theme, title: "Send Message With Reply Handler",
                onPressed: () {
              if (_isReachable) {
                _flutterWatchOsConnectivity.sendMessage({
                  "message":
                      "This is a message sent from IOS app with reply handler at ${DateTime.now().millisecondsSinceEpoch}"
                }, replyHandler: ((message) async {
                  setState(() {
                    _currentRepliedMessage = message;
                  });
                }));
              }
            }),
          ],
        ));
  }

  _updateApplicationContextSession(ThemeData theme) {
    return _section(theme,
        child: SpacingColumn(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10,
          children: [
            Text("Current application context:  ",
                style: theme.textTheme.headline6?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary)),
            Text(_applicationContext.currentData.toString()),
            Text("Received application context:  ",
                style: theme.textTheme.headline6?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary)),
            Text(_applicationContext.receivedData.toString()),
            _button(theme, title: "Update Application Context", onPressed: () {
              _flutterWatchOsConnectivity.updateApplicationContext({
                "message":
                    "Application Context updated by IOS app at ${DateTime.now().millisecondsSinceEpoch}"
              });
            }),
          ],
        ));
  }

  _sendUserInfoSession(ThemeData theme) {
    return _section(theme,
        child: SpacingColumn(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10,
          children: [
            Text("Received user info: ",
                style: theme.textTheme.headline6?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary)),
            Text(_receivedUserInfo.toString()),
            Text("Pending user info transfers: ",
                style: theme.textTheme.headline6?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary)),
            ..._userInfoPendingTransfers.map((transfer) => Row(
                  children: [
                    Expanded(
                      child: Text(
                          "${transfer.id}: " + transfer.userInfo.toString(),
                          style: theme.textTheme.headline6
                              ?.copyWith(fontWeight: FontWeight.w600)),
                    ),
                    CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(100)),
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: (() async {
                          try {
                            await transfer.cancel();
                          } catch (e) {
                            print(e);
                          }
                        }))
                  ],
                )),
            _button(theme, title: "Send user info", onPressed: () async {
              _flutterWatchOsConnectivity.transferUserInfo({
                "message":
                    "User info sent by IOS app at ${DateTime.now().millisecondsSinceEpoch}"
              }, isComplication: true);
              _pendingFileTransfers[0].cancel();
            }),
          ],
        ));
  }

  _transferFileSession(ThemeData theme) {
    return _section(theme,
        child: SpacingColumn(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 10,
            children: [
              Text("Received file: ",
                  style: theme.textTheme.headline6?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary)),
              if (_receivedFileData != null)
                Image.file(_receivedFileData!.left),
              Text("Metadata: ",
                  style: theme.textTheme.headline6?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary)),
              Text("${_receivedFileData?.right ?? ""}"),
              Text("Pending file transfers: ",
                  style: theme.textTheme.headline6?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary)),
              ..._pendingFileTransfers.map((transfer) => Row(
                    children: [
                      Expanded(
                        child: Text(
                            "${transfer.id}: " + transfer.file.toString(),
                            style: theme.textTheme.headline6
                                ?.copyWith(fontWeight: FontWeight.w600)),
                      ),
                      CupertinoButton(
                          padding: EdgeInsets.zero,
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(100)),
                            child: Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          onPressed: (() async {
                            try {
                              await transfer.cancel();
                            } catch (e) {
                              print(e);
                            }
                          }))
                    ],
                  )),
              _button(theme, title: "Transfer file", onPressed: () async {
                XFile? _file =
                    await ImagePicker().pickImage(source: ImageSource.gallery);
                if (_file != null) {
                  FileTransfer? _fileTransfer =
                      await _flutterWatchOsConnectivity
                          .transferFileInfo(File(_file.path));
                  if (_fileTransfer?.setOnProgressListener != null)
                    _fileTransfer?.setOnProgressListener(((progress) {
                      print("${_fileTransfer.id}: ${progress.currentProgress}");
                    }));
                }
              }),
            ]));
  }

  _section(ThemeData theme, {required Widget child}) {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Color(0xFFF2F2F2), borderRadius: BorderRadius.circular(14)),
      child: child,
    );
  }

  _button(ThemeData theme,
      {required String title, required VoidCallback onPressed}) {
    return CupertinoButton(
        padding: EdgeInsets.all(0),
        child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(10)),
            padding: EdgeInsets.all(14),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.subtitle2?.copyWith(color: Colors.white),
            )),
        onPressed: onPressed);
  }
}
