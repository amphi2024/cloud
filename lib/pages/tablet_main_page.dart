import 'package:amphi/models/app_localizations.dart';
import 'package:cloud/dialogs/file_detail_dialog.dart';
import 'package:cloud/views/files/files_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../channels/app_method_channel.dart';
import '../components/main_page_app_bar.dart';
import '../components/tablet_sidebar.dart';
import '../dialogs/edit_filename_dialog.dart';
import '../models/file_model.dart';
import '../models/fragment_index.dart';
import '../providers/files_provider.dart';
import '../providers/providers.dart';
import '../utils/file_utils.dart';
import '../utils/update_check.dart';

class TabletMainPage extends ConsumerStatefulWidget {
  const TabletMainPage({super.key});

  @override
  TabletMainPageState createState() => TabletMainPageState();
}

class TabletMainPageState extends ConsumerState<TabletMainPage> {
  bool sidebarShowing = true;
  final pageController = PageController();

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  @override
  void initState() {
    super.initState();
    checkForAppUpdate(context);
    checkForServerUpdate(context);
  }

  @override
  Widget build(BuildContext context) {
    appMethodChannel.setNavigationBarColor(Theme
        .of(context)
        .scaffoldBackgroundColor);
    final selectedItems = ref.watch(selectedFilesProvider);
    final searchKeyword = ref.watch(searchKeywordProvider);
    final fragmentIndex = ref.watch(fragmentIndexProvider);
    final sidebarWidth = ref.watch(sidebarWidthProvider);
    final filesState = ref.watch(filesProvider);
    final currentFolder = ref
        .watch(historyProvider)
        .lastOrNull ?? FileModel(id: "");
    final currentFolderId = ref
        .read(historyProvider.notifier)
        .currentFolder()
        .id;
    final history = ref.watch(historyProvider);
    ref.listen(historyProvider, (previous, next) {
      pageController.animateToPage(next.length - 1, duration: const Duration(milliseconds: 1000), curve: Curves.easeOutQuint);
    });

    return PopScope(
      canPop: selectedItems == null && history.isNotEmpty,
      onPopInvokedWithResult: (didPop, result) {
        if (selectedItems != null) {
          ref.read(selectedFilesProvider.notifier).endSelection();
          return;
        }
        if (history.isNotEmpty) {
          ref.read(historyProvider.notifier).pop();
          return;
        }
        if(searchKeyword != null) {
          ref.read(searchKeywordProvider.notifier).endSearch();
          return;
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            AnimatedPositioned(
              left: sidebarShowing ? sidebarWidth : 0,
              right: 0,
              bottom: 0,
              top: 0,
              curve: Curves.easeOutQuint,
              duration: const Duration(milliseconds: 500),
              child: Padding(
                padding: EdgeInsets.only(top: MediaQuery
                    .paddingOf(context)
                    .top),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedPadding(
                          padding: sidebarShowing ? EdgeInsets.zero : EdgeInsets.only(left: 40),
                          curve: Curves.easeOutQuint,
                          duration: const Duration(milliseconds: 500),
                          child: IconButton(
                            onPressed: () {
                              if (searchKeyword == null && fragmentIndex == FragmentIndex.files) {
                                ref.read(historyProvider.notifier).pop();
                              }
                            },
                            icon: Icon(
                              Icons.arrow_back_ios_new,
                              color: history.length > 1 && fragmentIndex == FragmentIndex.files ? null : Theme
                                  .of(context)
                                  .disabledColor,
                            ),
                          ),
                        ),
                        PopupMenuButton(
                          tooltip: "",
                          enabled: currentFolder.id.isNotEmpty,
                          icon: Text(
                            fragmentIndex == FragmentIndex.trash
                                ? AppLocalizations.of(context).get("@trash")
                                : currentFolderId.isEmpty
                                ? AppLocalizations.of(context).get("files")
                                : currentFolder.name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          itemBuilder: (context) {
                            return [
                              PopupMenuItem(
                                child: Text(AppLocalizations.of(context).get("details")),
                                onTap: () {
                                  showDialog(context: context, builder: (context) => FileDetailDialog(fileModel: currentFolder));
                                },
                              ),
                              PopupMenuItem(
                                child: Text(AppLocalizations.of(context).get("rename")),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder:
                                        (context) =>
                                        EditFilenameDialog(
                                          initialValue: currentFolder.name,
                                          onSave: (folderName) {
                                            renameFile(fileModel: currentFolder, filename: folderName, ref: ref, context: context);
                                          },
                                        ),
                                  );
                                },
                              ),
                            ];
                          },
                        ),
                        Expanded(child: SizedBox.shrink()),
                        ...appbarActions(
                          context: context,
                          fragmentIndex: fragmentIndex,
                          currentFolder: currentFolder,
                          selectedItems: selectedItems,
                          ref: ref,
                          files: filesState.files
                        ),
                        PopupMenuButton(
                          icon: Icon(Icons.add_circle_outline),
                          itemBuilder:
                              (context) =>
                          [
                            PopupMenuItem(
                              child: Text(AppLocalizations.of(context).get("new_folder")),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return EditFilenameDialog(
                                      initialValue: "",
                                      onSave: (folderName) {
                                        createFolder(folderName: folderName, parentFolderId: currentFolder.id, ref: ref, context: context);
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                            PopupMenuItem(
                              child: Text(AppLocalizations.of(context).get("new_file")),
                              onTap: () {
                                pickFilesAndUpload(currentFolderId: currentFolder.id, ref: ref, context: context);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    //TODO filter trash by search keyword
                    Expanded(
                      child: Stack(
                        children: [
                          Offstage(
                            offstage: fragmentIndex != FragmentIndex.files,
                            child: PageView.builder(
                              controller: pageController,
                              itemCount: history.length,
                              onPageChanged: (index) {
                                if (index == history.length - 2) {
                                  ref.read(historyProvider.notifier).pop();
                                }
                              },
                              itemBuilder: (context, index) {
                                return FilesGridView(
                                  files: filesState.idListByDirectoryId(history
                                      .elementAtOrNull(index)
                                      ?.id ?? "", filename: searchKeyword),
                                  placeholder: AppLocalizations.of(context).get("no_files"),
                                );
                              },
                            ),
                          ),
                          if (fragmentIndex == FragmentIndex.trash)
                            FilesGridView(files: filesState.trash, placeholder: AppLocalizations.of(context).get("no_files")),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            TabletSidebar(showing: sidebarShowing),
            Positioned(
              left: 0,
              top: MediaQuery
                  .of(context)
                  .padding
                  .top,
              child: IconButton(
                onPressed: () {
                  setState(() {
                    sidebarShowing = !sidebarShowing;
                  });
                },
                icon: const Icon(Icons.view_sidebar_outlined),
              ),
            ),
          ],
        ),
      ),
    );
  }
}