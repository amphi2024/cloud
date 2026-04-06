import 'dart:io';

import 'package:amphi/models/app_localizations.dart';
import 'package:amphi/widgets/dialogs/confirmation_dialog.dart';
import 'package:amphi/widgets/window/adaptive_linux_window_buttons.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:cloud/utils/delete_files.dart';
import 'package:cloud/utils/export_file.dart';
import 'package:cloud/views/files/desktop_file_grid_item.dart';
import 'package:cloud/components/thumbnail/file_thumbnail.dart';
import 'package:cloud/components/history_bar.dart';
import 'package:cloud/components/main_page_app_bar.dart';
import 'package:cloud/dialogs/file_detail_dialog.dart';
import 'package:cloud/models/file_model.dart';
import 'package:cloud/models/fragment_index.dart';
import 'package:cloud/providers/desktop_listview_controller_provider.dart';
import 'package:cloud/providers/files_provider.dart';
import 'package:cloud/providers/providers.dart';
import 'package:cloud/utils/move_files.dart';
import 'package:desktop_listview/desktop_listview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/custom_window_button.dart';
import '../components/sidebar.dart';
import '../dialogs/edit_filename_dialog.dart';
import '../models/app_settings.dart';
import '../providers/csd_themes_provider.dart';
import '../utils/file_utils.dart';
import '../utils/on_file_pressed.dart';
import '../utils/update_check.dart';
import '../utils/window_control.dart';

const double desktopTitleBarHeight = 50;

class DesktopMainPage extends ConsumerStatefulWidget {
  const DesktopMainPage({super.key});

  @override
  WideMainPageState createState() => WideMainPageState();
}

class WideMainPageState extends ConsumerState<DesktopMainPage> {

  @override
  void initState() {
    super.initState();
    checkForAppUpdate(context);
    checkForServerUpdate(context);
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(desktopListviewControllerProvider);
    final searchKeyword = ref.watch(searchKeywordProvider);
    final fragmentIndex = ref.watch(fragmentIndexProvider);
    final history = ref.watch(historyProvider);
    final currentFolder = history.lastOrNull ?? FileModel(id: "");
    final selectedItems = ref.watch(selectedFilesProvider);
    final actions = appbarActions(
      context: context,
      fragmentIndex: fragmentIndex,
      currentFolder: currentFolder,
      selectedItems: selectedItems,
      ref: ref
    );
    final csdThemes = ref.watch(csdThemesProvider).themes;
    final csdTheme = csdThemes[appSettings.selectedWindowButtonsTheme];

    final colors = CustomWindowButtonColors(
      iconMouseOver: Theme.of(context).textTheme.bodyMedium?.color,
      mouseOver: const Color.fromRGBO(125, 125, 125, 0.1),
      iconNormal: Theme.of(context).textTheme.bodyMedium?.color,
      mouseDown: const Color.fromRGBO(125, 125, 125, 0.1),
      iconMouseDown: Theme.of(context).textTheme.bodyMedium?.color,
      normal: Theme.of(context).scaffoldBackgroundColor,
    );

    final filesState = ref.watch(filesProvider);
    final files = filesState.files;
    final currentFolderId = currentFolder.id;
    final idList =
        fragmentIndex == FragmentIndex.trash
            ? filesState.trash
            : filesState.idListByDirectoryId(currentFolder.id, filename: searchKeyword);
    final sidebarWidth = ref.watch(sidebarWidthProvider);

    return Scaffold(
      body: Stack(
        children: [
          Positioned(left: 0, top: 0, bottom: 0, child: Sidebar()),
          Positioned(
            left: sidebarWidth,
            right: 0,
            bottom: 0,
            top: 0,
            child: Column(
              children: [
                SizedBox(
                  height: desktopTitleBarHeight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: IconButton(
                          onPressed: () {
                            if (ref.read(selectedFilesProvider) == null) {
                              ref.read(historyProvider.notifier).pop();
                            }
                          },
                          icon: Icon(Icons.arrow_back_ios_new, color: history.length > 1 ? null : Theme.of(context).disabledColor),
                        ),
                      ),
                      Expanded(child: SizedBox(height: desktopTitleBarHeight, child: MoveWindow())),
                      HistoryBar(),
                      Expanded(child: SizedBox(height: desktopTitleBarHeight, child: MoveWindow())),
                      Row(
                        children: [
                          ...actions,
                          if (Platform.isWindows) ...[
                            MinimizeCustomWindowButton(colors: colors),
                            appWindow.isMaximized
                                ? RestoreCustomWindowButton(
                                  colors: colors,
                                  onPressed: () {
                                    appWindow.restore();
                                  },
                                )
                                : MaximizeCustomWindowButton(
                                  colors: colors,
                                  onPressed: () {
                                    appWindow.maximize();
                                  },
                                ),
                            CloseCustomWindowButton(
                              colors: CustomWindowButtonColors(
                                mouseOver: const Color(0xFFD32F2F),
                                mouseDown: const Color(0xFFB71C1C),
                                iconNormal: Theme.of(context).textTheme.bodyMedium!.color,
                                iconMouseOver: const Color(0xFFFFFFFF),
                                normal: Theme.of(context).scaffoldBackgroundColor,
                              ),
                            ),
                          ],
                          if (Platform.isLinux && appSettings.prefersCustomTitleBar && !appSettings.windowButtonsOnLeft) AdaptiveLinuxWindowButtons(theme: csdTheme, padding: 4.5, onClose: saveWindowSize, windowButtonsOnLeft: false)
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: DesktopGridview(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    onSecondaryTapUp: (details) {
                      showContextMenu(
                        context,
                        contextMenu: ContextMenu(
                          position: details.globalPosition,
                          padding: EdgeInsets.zero,
                          entries: [
                            TextMenuItem(
                              label: Text(AppLocalizations.of(context).get("new_folder")),
                              onSelected: (d) {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return EditFilenameDialog(
                                      initialValue: "",
                                      onSave: (folderName) {
                                        createFolder(folderName: folderName, parentFolderId: currentFolderId, ref: ref, context: context);
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                            TextMenuItem(
                              label: Text(AppLocalizations.of(context).get("new_file")),
                              onSelected: (d) {
                                pickFilesAndUpload(currentFolderId: currentFolderId, ref: ref, context: context);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                    onKeyEvent: (keyEvent) {
                      if (controller.ctrlPressed) {
                        switch(keyEvent.physicalKey) {
                          case PhysicalKeyboardKey.keyA:
                            controller.addAll(idList);
                            break;
                          // case PhysicalKeyboardKey.minus:
                          //
                          //   break;
                          // case PhysicalKeyboardKey.equal:
                          //
                          //   break;
                          case PhysicalKeyboardKey.keyT:
                            //TODO: implement multiple tap
                            break;
                        }
                      }
                    },
                    controller: controller,
                    itemCount: idList.length,
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      childAspectRatio: 0.8,
                      mainAxisSpacing: 0,
                      crossAxisSpacing: 0,
                    ),
                    itemBuilder: (context, index) {
                      final fileModel = files.get(idList[index]);
                      return DesktopListviewItem(
                        id: idList[index],
                        controller: controller,
                        dragFeedback: Material(color: Colors.transparent, child: FileThumbnail(fileModel: fileModel, iconSize: 50)),
                        dragFeedbackOffset: Offset.zero,
                        onPressed: () {
                          onFilePressed(fileModel: fileModel, context: context, ref: ref);
                        },
                        onSecondaryTapUp: (details) {
                          if (controller.selectedItems.isNotEmpty && fragmentIndex == FragmentIndex.trash) {
                            showContextMenu(
                              context,
                              contextMenu: ContextMenu(
                                position: details.globalPosition,
                                entries: [
                                  TextMenuItem(
                                    label: Text(AppLocalizations.of(context).get("delete")),
                                    onSelected: (d) {
                                      showDialog(
                                        context: context,
                                        builder:
                                            (context) => ConfirmationDialog(
                                              title: AppLocalizations.of(context).get("@dialog_title_delete_selected_files"),
                                              onConfirmed: () {
                                                permanentlyDeleteSelectedFiles(
                                                  ref: ref,
                                                  selectedIds: controller.selectedItems,
                                                  desktopListviewController: controller,
                                                );
                                              },
                                            ),
                                      );
                                    },
                                  ),
                                  TextMenuItem(
                                    label: Text(AppLocalizations.of(context).get("restore")),
                                    onSelected: (d) {
                                      restoreSelectedFiles(ref: ref, selectedIds: controller.selectedItems, desktopListviewController: controller);
                                    },
                                  ),
                                ],
                              ),
                            );
                          } else {
                            showContextMenu(
                              context,
                              contextMenu: ContextMenu(
                                position: details.globalPosition,
                                entries: [
                                  TextMenuItem(
                                    label: Text(AppLocalizations.of(context).get("details")),
                                    onSelected: (d) {
                                      showDialog(context: context, builder: (context) => FileDetailDialog(fileModel: fileModel));
                                    },
                                  ),
                                  TextMenuItem(
                                    label: Text(AppLocalizations.of(context).get("rename")),
                                    onSelected: (d) {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return EditFilenameDialog(
                                            initialValue: fileModel.name,
                                            onSave: (folderName) {
                                              renameFile(fileModel: fileModel, filename: folderName, ref: ref, context: context);
                                            },
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  if(!fileModel.isFolder) ... [
                                    TextMenuItem(
                                      label: Text(AppLocalizations.of(context).get("export")),
                                      onSelected: (d) async {
                                        exportFile(fileModel: fileModel, context: context, ref: ref);
                                      },
                                    ),
                                    TextMenuItem(
                                      label: Text(AppLocalizations.of(context).get(fileModel.isAvailableOffline ? "make_online_only" : "make_available_offline")),
                                      onSelected: (d) async {
                                        if(fileModel.isAvailableOffline) {
                                          fileModel.removeDownload(ref: ref);
                                        }
                                        else {
                                          fileModel.makeAvailableOnOffline(ref: ref);
                                        }
                                      },
                                    ),
                                  ]
                                ],
                              ),
                            );
                          }
                        },
                        child: DragTarget<Set<String>>(
                          onAcceptWithDetails: (details) {
                            moveSelectedFiles(
                              selectedIds: details.data,
                              oldParentId: currentFolderId,
                              ref: ref,
                              files: files,
                              parent: fileModel,
                              desktopListviewController: controller,
                            );
                          },
                          builder: (context, candidateData, rejectedData) {
                            return Hero(tag: fileModel.id, child: DesktopFileGridItem(fileModel: fileModel));
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
