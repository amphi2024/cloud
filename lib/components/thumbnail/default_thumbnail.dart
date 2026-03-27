import 'package:flutter/material.dart';

import '../../models/file_model.dart';

class DefaultThumbnail extends StatelessWidget {

  final FileModel fileModel;
  final double iconSize;
  const DefaultThumbnail({super.key, required this.fileModel, required this.iconSize});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: iconSize,
      height: iconSize,
      child: Stack(
        children: [
          Center(child: Image.asset("assets/icons/file.png", cacheWidth: iconSize.toInt())),
          Center(child: Text(fileModel.fileExtension.toUpperCase(), style: TextStyle(color: Color.fromARGB(255, 55, 55, 55), fontSize: iconSize / 5)))
        ],
      ),
    );
  }
}