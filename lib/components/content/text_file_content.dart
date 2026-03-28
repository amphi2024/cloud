import 'dart:io';

import 'package:amphi/models/app_localizations.dart';
import 'package:cloud/components/thumbnail/file_thumbnail.dart';
import 'package:cloud/utils/screen_size.dart';
import 'package:cloud/views/desktop_text_file_view.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../channels/app_web_channel.dart';
import '../../models/file_model.dart';
import '../../utils/toast.dart';

const maximumTextFileSize = 5 * 1024 * 1024;

class TextFileContent extends StatefulWidget {

  final FileModel fileModel;
  final double iconSize;
  const TextFileContent({super.key, required this.fileModel, required this.iconSize});

  @override
  State<TextFileContent> createState() => _TextFileContentState();
}

class _TextFileContentState extends State<TextFileContent> {

  String? fileContent;
  int receivedBytes = 0;
  int totalBytes = 0;

  Future<void> init() async {
    final file = File(widget.fileModel.temporaryPath);
    if(await file.exists()) {
      final content = await file.readAsString();
      if(mounted) {
        setState(() {
          fileContent = content;
        });
      }
    }
    else {
      if(widget.fileModel.size > maximumTextFileSize) {
        return;
      }
      appWebChannel.downloadFileFromCloud(
        id: widget.fileModel.id,
        filePath: widget.fileModel.temporaryPath,
        onSuccess: () async {
          final content = await file.readAsString();
          if(mounted) {
            setState(() {
              fileContent = content;
            });
          }
        },
        onProgress: (receivedLength, length) {
          if(mounted) {
            setState(() {
              totalBytes = length;
              receivedBytes = receivedLength;
            });
          }
        },
        onFailed: (code) {
          showToast(context, "${AppLocalizations.of(context).get("failed_load_file")}. Error code: $code");
        },
      );
    }
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant TextFileContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    init();
  }


  @override
  Widget build(BuildContext context) {
    if(fileContent == null) {
      if(widget.fileModel.size > maximumTextFileSize) {
        return FileThumbnail(fileModel: widget.fileModel, iconSize: widget.iconSize);
      }
      return CircularPercentIndicator(
          radius: 50,
          lineWidth: 5,
          animation: false,
          percent: (receivedBytes / totalBytes).toDouble(),
          progressColor: Theme.of(context).highlightColor);
    }
    else {
      final result = SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SelectableText(
            fileContent!
          ),
        ),
      );

      if(isDesktop()) {
        return DesktopTextFileView(child: result);
      }
      return result;
    }
  }
}
