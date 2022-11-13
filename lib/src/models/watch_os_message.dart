part of models;

class WatchOSMessage {
  ///A [Map] represented for each message map data.
  final Map<String, dynamic> data;

  ///A optional callback method to indicate whether this message is waiting for reply.
  final MessageReplyHandler? replyMessage;
  WatchOSMessage({required this.data, this.replyMessage});
}
