part of helpers;

typedef MessageReplyHandler = Future<void> Function(
    Map<String, dynamic> message);

typedef ProgressHandler = Function(Progress);
