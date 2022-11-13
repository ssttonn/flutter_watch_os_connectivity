part of models;

class UserInfoTransfer {
  ///A [String] used to uniquely identify the [UserInfoTransfer].
  final String id;

  ///A [bool] indicating whether the data is related to the app’s complication
  final bool isCurrentComplicationInfo;

  ///The [Map] data being transferred.
  final Map<String, dynamic> userInfo;

  ///A [bool] indicating whether the data is being tranfered.
  final bool isTransfering;

  ///A method used to cancel the [UserInfoTransfer]
  Future<void> Function() cancel = () async {};

  UserInfoTransfer(
      {required this.id,
      required this.isCurrentComplicationInfo,
      required this.userInfo,
      required this.isTransfering});

  factory UserInfoTransfer.fromJson(Map<String, dynamic> json) =>
      UserInfoTransfer(
        id: json['id'] as String? ?? '',
        isCurrentComplicationInfo:
            json['isCurrentComplicationInfo'] as bool? ?? false,
        userInfo: fromRawMapToMapStringKeys(json['userInfo'] as Map),
        isTransfering: json['isTransfering'] as bool? ?? false,
      );
}
