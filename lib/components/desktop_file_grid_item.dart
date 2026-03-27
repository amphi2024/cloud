import 'package:cloud/models/file_model.dart';
import 'package:flutter/material.dart';
import 'thumbnail/file_thumbnail.dart';

class DesktopFileGridItem extends StatelessWidget {

  final FileModel fileModel;
  const DesktopFileGridItem({super.key, required this.fileModel});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
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
    );
  }
}