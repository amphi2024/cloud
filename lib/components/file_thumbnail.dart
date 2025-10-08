import 'package:flutter/material.dart';

import '../channels/app_web_channel.dart';
import '../models/app_settings.dart';
import '../models/file_model.dart';

class FileThumbnail extends StatelessWidget {
  final FileModel fileModel;
  final double iconSize;
  final BoxFit? fit;

  const FileThumbnail({super.key, required this.fileModel, required this.iconSize, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    if (fileModel.isFolder) {
      return Icon(Icons.folder, size: iconSize);
    }
    switch (fileModel.fileExtension) {
      case "webp":
      case "jpg":
      case "jpeg":
      case "png":
      case "gif":
      case "bmp":
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: iconSize,
            height: iconSize,
            child: Image(
              image: NetworkImage("${appSettings.serverAddress}/cloud/files/${fileModel.id}/download", headers: {"Authorization": appWebChannel.token}),
              fit: fit,
            ),
          ),
        );
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
      default:
        return Icon(Icons.file_copy, size: iconSize);
    }
  }
}

class FileThumbnailRounded extends StatelessWidget {
  const FileThumbnailRounded({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
