import 'package:cloud/components/thumbnail/default_thumbnail.dart';
import 'package:cloud/components/thumbnail/video_thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../channels/app_web_channel.dart';
import '../../models/app_settings.dart';
import '../../models/file_model.dart';

class FileThumbnail extends StatelessWidget {
  final FileModel fileModel;
  final double iconSize;
  final BoxFit? fit;

  const FileThumbnail({super.key, required this.fileModel, required this.iconSize, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    if (fileModel.isFolder) {
      final highlightColor = Theme.of(context).highlightColor;
      return SizedBox(
        width: iconSize,
        height: iconSize,
        child: Stack(
          children: [
            Center(
              child: SvgPicture.asset("assets/icons/folder_back.svg", width: iconSize,
                  colorFilter: ColorFilter.mode(highlightColor, BlendMode.srcIn)
              ),
            ),
            Center(
              child: SvgPicture.asset("assets/icons/folder_front.svg", width: iconSize,
                  colorFilter: ColorFilter.mode(Color.lerp(highlightColor, Colors.white, 0.3) ?? highlightColor, BlendMode.srcIn)
              ),
            ),
          ],
        ),
      );
    }
    switch (fileModel.fileExtension) {
      case "webp":
      case "jpg":
      case "jpeg":
      case "png":
      case "gif":
      case "bmp":
        return SizedBox(
          width: iconSize,
          height: iconSize,
          child: Image(
            image: NetworkImage("${appSettings.serverAddress}/cloud/files/${fileModel.id}/download", headers: {"Authorization": appWebChannel.token}),
            fit: fit,
            errorBuilder: (context, error, stackTrace) => DefaultThumbnail(fileModel: fileModel, iconSize: iconSize)
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
        return VideoThumbnail(fileModel: fileModel, iconSize: iconSize);
      case "pdf":
        return SizedBox(
          width: iconSize,
          height: iconSize,
          child: Image.asset("assets/icons/pdf.png", cacheWidth: iconSize.toInt()),
        );
      case "odt":
      case "rtf":
      case "doc":
      case "docx":
        return SizedBox(
          width: iconSize,
          height: iconSize,
          child: Image.asset("assets/icons/word.png", cacheWidth: iconSize.toInt()),
        );
      case "txt":
        return SizedBox(
          width: iconSize,
          height: iconSize,
          child: Image.asset("assets/icons/text.png", cacheWidth: iconSize.toInt()),
        );
      default:
        return DefaultThumbnail(fileModel: fileModel, iconSize: iconSize);
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
