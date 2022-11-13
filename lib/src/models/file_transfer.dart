part of models;

class FileTransfer {
  final String id;

  final File? file;

  final bool isTransfering;

  final Map<String, dynamic>? metadata;

  // @JsonKey(ignore:  true)
  Future<void> Function() cancel = () async {};

  late void Function(void Function(Progress)) setOnProgressListener;

  FileTransfer(
      {required this.id,
      required this.file,
      this.isTransfering = false,
      this.metadata});
  factory FileTransfer.fromJson(Map<String, dynamic> json) => FileTransfer(
      id: json['id'] as String? ?? '',
      file: fileFromPath(json['filePath'] as String?),
      isTransfering: json['isTransfering'] as bool? ?? false,
      metadata: fromRawMapToMapStringKeys(json['metadata'] as Map? ?? {}));
}

class Progress {
  final int currentProgress;
  final int estimateTimeLeft;

  Progress({required this.currentProgress, required this.estimateTimeLeft});

  factory Progress.fromJson(Map<String, dynamic> json) {
    return Progress(
        currentProgress: json['currentProgress'] as int? ?? 0,
        estimateTimeLeft: 0);
  }
}
