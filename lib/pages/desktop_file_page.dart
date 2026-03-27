import 'package:cloud/providers/files_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/content/file_content.dart';

class DesktopFilePage extends ConsumerStatefulWidget {
  final String id;

  const DesktopFilePage({super.key, required this.id});

  @override
  DesktopFilePageState createState() => DesktopFilePageState();
}

class DesktopFilePageState extends ConsumerState<DesktopFilePage> {

  @override
  Widget build(BuildContext context) {
    final fileModel = ref
        .watch(filesProvider)
        .files
        .get(widget.id);
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: Color.fromARGB(125, 0, 0, 0),
        body: Stack(
          children: [
            Positioned.fill(child: Hero(tag: widget.id, child: FileContent(fileModel: fileModel, iconSize: 50))),

          ],
        ),
      ),
    );
  }
}
