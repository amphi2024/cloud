import 'package:amphi/models/app_localizations.dart';
import 'package:cloud/components/main_page_app_bar.dart';
import 'package:cloud/models/file_model.dart';
import 'package:cloud/models/fragment_index.dart';
import 'package:cloud/providers/files_provider.dart';
import 'package:cloud/providers/providers.dart';
import 'package:cloud/views/files_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TrashPage extends ConsumerWidget {
  const TrashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final selectedFiles = ref.watch(selectedFilesProvider);
    final actions = appbarActions(context: context, fragmentIndex: FragmentIndex.trash, currentFolder: FileModel(id: ""), selectedItems: selectedFiles, ref: ref);

    return PopScope(
      canPop: selectedFiles == null,
      onPopInvokedWithResult: (didPop, result) {
        if(selectedFiles != null) {
          ref.read(selectedFilesProvider.notifier).endSelection();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 60,
          leading: Builder(
            builder: (context) {
              return IconButton(onPressed: () {
                Navigator.pop(context);
              }, icon: Icon(Icons.arrow_back_ios_new));
            },
          ),
          title: Text(AppLocalizations.of(context).get("@trash")),
          centerTitle: true,
          actions: actions,
        ),
        body: Stack(
          children: [
            FilesGridView(files: ref.read(filesProvider).trash, placeholder: AppLocalizations.of(context).get("no_files_in_trash"))
          ],
        ),
      ),
    );
  }
}
