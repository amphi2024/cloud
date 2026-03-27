enum TransferType { upload, download }

class TransferState {
  final String fileId;
  final int transferredBytes;
  final int totalBytes;

  const TransferState({
    required this.fileId,
    required this.transferredBytes,
    required this.totalBytes
  });

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is TransferState &&
            runtimeType == other.runtimeType &&
            fileId == other.fileId;
  }

  @override
  int get hashCode => fileId.hashCode;
}