import 'package:cloud/models/file_model.dart';
import 'package:flutter/material.dart';
import '../../components/thumbnail/file_thumbnail.dart';
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
                  child: Text(
                      fileModel.name,
                      maxLines: 3, textAlign: TextAlign.center,
                      style: TextStyle(
                          overflow: TextOverflow.ellipsis
                      )),
                ),
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