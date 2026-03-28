import 'package:cloud/views/files/file_grid_item.dart';
import 'package:cloud/utils/on_file_pressed.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/files_provider.dart';

class FilesGridView extends ConsumerStatefulWidget {
  final String placeholder;
  final List<String> files;

  const FilesGridView({super.key, required this.files, required this.placeholder});

  @override
  FilesViewState createState() => FilesViewState();
}

class FilesViewState extends ConsumerState<FilesGridView> {

  Future<void> refresh() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    ref.read(filesProvider.notifier).init();
  }

  @override
  Widget build(BuildContext context) {
    final idList = widget.files;
    final files = ref
        .watch(filesProvider)
        .files;
    if (idList.isEmpty) {
      return RefreshIndicator(
        onRefresh: refresh,
        child: ListView(
          children: [
            Center(child: Text(widget.placeholder)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: refresh,
      child: GridView.builder(
          itemCount: idList.length,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 150, // max width of each item
            childAspectRatio: 0.7,   // width / height ratio
            mainAxisSpacing: 0,
            crossAxisSpacing: 0,
          ),
          itemBuilder: (context, index) {
            final fileModel = files.get(idList[index]);
            return Hero(
              tag: fileModel.id,
              child: FileGridItem(fileModel: fileModel, onPressed: () {
                onFilePressed(fileModel: fileModel, context: context, ref: ref);
              }),
            );
          }),
    );
  }
}