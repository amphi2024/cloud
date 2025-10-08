import 'package:cloud/components/content/file_content.dart';
import 'package:cloud/components/popup_menu_items.dart';
import 'package:cloud/providers/files_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FilePage extends ConsumerStatefulWidget {

  final String id;
  const FilePage({super.key, required this.id});

  @override
  FilePageState createState() => FilePageState();
}

class FilePageState extends ConsumerState<FilePage> {

  late Color backgroundColor = Theme
      .of(context)
      .scaffoldBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final id = widget.id;
    final fileModel = ref.watch(filesProvider).files.get(id);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        leading: IconButton(onPressed: () {
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back_ios)),
        title: Text(fileModel.name, style: TextStyle(
          overflow: TextOverflow.ellipsis
        )),
        centerTitle: true,
        actions: [
          PopupMenuButton(itemBuilder: (context) {
            return filePagePopupMenuItems(context: context, fileModel: fileModel, ref: ref);
          })
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(child:  FileContent(fileModel: fileModel, iconSize: 50))
        ],
      ),
    );
  }
}
