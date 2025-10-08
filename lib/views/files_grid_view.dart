import 'package:amphi/models/app.dart';
import 'package:cloud/components/file_grid_item.dart';
import 'package:cloud/models/file_model.dart';
import 'package:cloud/pages/file_page.dart';
import 'package:cloud/pages/main_page.dart';
import 'package:cloud/providers/providers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/files_provider.dart';

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

  void onItemPressed(FileModel fileModel) {
    if(fileModel.deleted != null) {
      return;
    }
    if(fileModel.isFolder) {
      if(App.isWideScreen(context) || App.isDesktop()) {
        ref.read(historyProvider.notifier).insertHistory(fileModel);
      }
      else {
        Navigator.push(context, CupertinoPageRoute(builder: (context) => MainPage(folder: fileModel)));
      }
    }
    else {
      if(App.isDesktop()) {
        ref.read(showingFileProvider.notifier).toggleVisibility(fileModel);
      }
      else {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => FilePage(id: fileModel.id),
        ));
      }
    }
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

    int axisCount = 2;
    if(App.isWideScreen(context) || App.isDesktop()) {
      final itemSize = 175;
      axisCount = (MediaQuery.of(context).size.width / itemSize).toInt();
    }
    if (axisCount < 1) {
      axisCount = 1;
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
            return FileGridItem(fileModel: files.get(idList[index]), onPressed: () {
              if (ref.read(selectedFilesProvider) == null) {
                onItemPressed(files.get(idList[index]));
              }
            });
          }),
    );
  }
}