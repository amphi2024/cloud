import 'package:cloud/providers/transfers_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class FileUploadProgress extends ConsumerWidget {
  final String fileId;
  const FileUploadProgress({super.key, required this.fileId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transferState = ref.watch(transfersProvider)[fileId];
    if(transferState == null) {
      return SizedBox.shrink();
    }
    return CircularPercentIndicator(
        radius: 10,
        lineWidth: 5,
        animation: false,
        percent: (transferState.transferredBytes / transferState.totalBytes).toDouble(),
        progressColor: Theme.of(context).highlightColor);
  }
}
