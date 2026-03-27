import 'package:cloud/channels/app_web_channel.dart';
import 'package:cloud/models/file_model.dart';
import 'package:flutter/material.dart';

import 'default_thumbnail.dart';

class VideoThumbnail extends StatelessWidget {

  final FileModel fileModel;
  final double iconSize;
  const VideoThumbnail({super.key, required this.fileModel, required this.iconSize});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: iconSize,
      height: iconSize,
      child: Image.network("${appWebChannel.serverAddress}/cloud/files/${fileModel.id}/thumbnail", headers: {
        "Authorization": appWebChannel.token
      },
          cacheHeight: iconSize.toInt(),
      errorBuilder: (context, error, stackTrace) {
        return DefaultThumbnail(fileModel: fileModel, iconSize: iconSize);
      }),
    );
  }
}