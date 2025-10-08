import 'package:cloud/providers/files_provider.dart';
import 'package:cloud/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/file_grid_item.dart';
import '../models/file_model.dart';

class SelectFolderDialog extends ConsumerStatefulWidget {

  final List<String> excluding;
  final String currentFolderId;
  const SelectFolderDialog({super.key, required this.excluding, required this.currentFolderId});

  @override
  ConsumerState<SelectFolderDialog> createState() => _SelectFolderDialogState();
}

class _SelectFolderDialogState extends ConsumerState<SelectFolderDialog> {

  Map<String, List<FileModel>> files = {};
  List<String> history = [""];

  void initFiles(String location) {
    files[location] = [];
    for(var id in ref.read(filesProvider).idListByDirectoryId(location)) {
      final fileModel = ref.read(filesProvider).files.get(id);
      if(fileModel.isFolder && !widget.excluding.contains(fileModel.id)) {
        files[location]!.add(fileModel);
        initFiles(fileModel.id);
      }
    }
  }

  @override
  void initState() {
    initFiles("");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
          width: 250,
          height: 500,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(onPressed: () {
                    Navigator.pop(context);
                  }, icon: Icon(Icons.cancel_outlined)),
                  IconButton(onPressed: () {
                    ref.read(filesProvider.notifier).moveFiles(ref.read(selectedFilesProvider)!, widget.currentFolderId, history.last);
                    ref.read(selectedFilesProvider.notifier).endSelection();
                    Navigator.pop(context);
                  }, icon: Icon(Icons.check_circle_outline)),
                ],
              ),
              if(history.length > 1) ...[
                Row(
                  children: [
                    IconButton(onPressed: () {
                      setState(() {
                        history.removeLast();
                      });
                    }, icon: Icon(Icons.arrow_back_ios_new))
                ],)
              ],
              Expanded(
                child: GridView.builder(
                    itemCount: files[history.last]!.length,
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 150, // max width of each item
                      childAspectRatio: 0.7, // width / height ratio
                      mainAxisSpacing: 0,
                      crossAxisSpacing: 0,
                    ),
                    itemBuilder: (context, index) {
                      final fileModel = files[history.last]![index];
                      return FileGridItem(
                          hideCheckbox: true,
                          fileModel: fileModel, onPressed: () {
                            setState(() {
                              history.add(fileModel.id);
                            });
                      });
                    }),
              ),
            ],
          )
      ),
    );
  }
}
