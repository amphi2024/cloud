import 'package:cloud/models/file_model.dart';
import 'package:flutter/material.dart';
import '../../components/thumbnail/file_thumbnail.dart';
import '../../utils/trucate_text.dart';
import 'file_upload_progress.dart';

class DesktopFileGridItem extends StatelessWidget {

  final FileModel fileModel;
  const DesktopFileGridItem({super.key, required this.fileModel});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: Column(
              children: [
                FileThumbnail(fileModel: fileModel, iconSize: 100, fit: BoxFit.contain),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: Text.rich(
                    maxLines: 3,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    TextSpan(
                      children: [
                        TextSpan(text: truncateText(fileModel.name, 15)),
                        if(!fileModel.isAvailableOffline) WidgetSpan(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: Icon(Icons.cloud_download_outlined, size: Theme.of(context).textTheme.bodyMedium?.fontSize,),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          Positioned(
              right: 0,
              bottom: 0,
              child: FileUploadProgress(fileId: fileModel.id))
        ],
      ),
    );
  }
}