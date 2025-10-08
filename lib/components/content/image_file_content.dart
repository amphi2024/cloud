import 'package:flutter/material.dart';

import '../../channels/app_web_channel.dart';
import '../../models/app_settings.dart';
import '../../models/file_model.dart';

class ImageFileContent extends StatelessWidget {

  final FileModel fileModel;
  const ImageFileContent({super.key, required this.fileModel});

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      child: Image(
        image: NetworkImage(
          "${appSettings.serverAddress}/cloud/files/${fileModel.id}/download",
          headers: {"Authorization": appWebChannel.token},
        ),
      ),
    );
  }
}
