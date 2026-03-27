import 'package:cloud/components/content/image_file_content.dart';
import 'package:cloud/components/content/pdf_file_content.dart';
import 'package:cloud/components/content/text_file_content.dart';
import 'package:cloud/models/file_model.dart';
import 'package:flutter/material.dart';

import '../video_player.dart';

class FileContent extends StatelessWidget {
  final FileModel fileModel;
  final double iconSize;

  const FileContent({
    super.key,
    required this.fileModel,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    switch (fileModel.fileExtension) {
      case "webp":
      case "jpg":
      case "jpeg":
      case "png":
      case "gif":
      case "bmp":
        return ImageFileContent(fileModel: fileModel);
      case "mp4":
      case "mov":
      case "avi":
      case "wmv":
      case "mkv":
      case "flv":
      case "webm":
      case "mpeg":
      case "mpg":
      case "m4v":
      case "3gp":
      case "3g2":
      case "f4v":
      case "swf":
      case "vob":
      case "ts":
        return VideoPlayer(fileModel: fileModel);
      case "pdf":
        return PdfFileContent(fileModel: fileModel);
      default:
        return TextFileContent(fileModel: fileModel, iconSize: iconSize);
    }
  }
}
