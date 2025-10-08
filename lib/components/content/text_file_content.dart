import 'dart:convert';

import 'package:amphi/models/app_localizations.dart';
import 'package:cloud/components/file_thumbnail.dart';
import 'package:flutter/material.dart';

import '../../channels/app_web_channel.dart';
import '../../models/file_model.dart';
import '../../utils/toast.dart';

class TextFileContent extends StatefulWidget {

  final FileModel fileModel;
  final double iconSize;
  const TextFileContent({super.key, required this.fileModel, required this.iconSize});

  @override
  State<TextFileContent> createState() => _TextFileContentState();
}

class _TextFileContentState extends State<TextFileContent> {

  String? fileContent;
  int received = 0;
  int fileSize = 0;

  void init() {
    appWebChannel.downloadFileFromCloud(
      id: widget.fileModel.id,
      onSuccess: (bytes) {
        try {
          setState(() {
            fileContent = utf8.decode(bytes);
          });
        }
        catch(e) {
          setState(() {
            fileContent = null;
          });
        }
      },
      onProgress: (receivedLength, length) {
        setState(() {
          fileSize = length;
          received = receivedLength;
        });
      },
      onFailed: (code) {
        showToast(context, "${AppLocalizations.of(context).get("failed_load_file")}. Error code: $code");
      },
    );
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
      return Center(child: FileThumbnail(fileModel: widget.fileModel, iconSize: widget.iconSize));
    }
    else {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SelectableText(
            fileContent!,
            maxLines: 5000,
          ),
        ),
      );
    }
  }
}
