import 'dart:io';

import 'package:amphi/models/app_localizations.dart';
import 'package:amphi/widgets/account/account_button.dart';
import 'package:amphi/widgets/window/adaptive_linux_window_buttons.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:cloud/models/file_model.dart';
import 'package:cloud/providers/desktop_listview_controller_provider.dart';
import 'package:cloud/providers/files_provider.dart';
import 'package:cloud/utils/delete_files.dart';
import 'package:cloud/utils/move_files.dart';
import 'package:cloud/utils/screen_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../channels/app_method_channel.dart';
import '../channels/app_web_channel.dart';
import '../models/app_cache.dart';
import '../models/app_settings.dart';
import '../models/app_storage.dart';
import '../models/fragment_index.dart';
import '../providers/csd_themes_provider.dart';
import '../providers/providers.dart';
import '../utils/account_utils.dart';
import '../utils/window_control.dart';
import '../views/settings_view.dart';

class Sidebar extends ConsumerWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFolderId = ref
        .watch(historyProvider.notifier)
        .currentFolder()
        .id;
    final files = ref.watch(filesProvider).files;
    final desktopListviewController = ref.watch(desktopListviewControllerProvider);
    final fragmentIndex = ref.watch(fragmentIndexProvider);
    final width = ref.watch(sidebarWidthProvider);
    final csdThemes = ref.watch(csdThemesProvider).themes;
    final csdTheme = csdThemes[appSettings.selectedWindowButtonsTheme];

    return Container(
      width: width,
      color: Theme
          .of(context)
          .navigationDrawerTheme
          .backgroundColor,
      child: Stack(
        children: [
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (Platform.isLinux && appSettings.prefersCustomTitleBar && appSettings.windowButtonsOnLeft)
                      AdaptiveLinuxWindowButtons(theme: csdTheme, padding: 4.5, onClose: saveWindowSize, windowButtonsOnLeft: true),
                    Expanded(child: SizedBox(height: 50, child: MoveWindow())),
                    AccountButton(
                      onLoggedIn: ({required id, required token, required username}) {
                        onLoggedIn(id: id,
                            token: token,
                            username: username,
                            context: context,
                            ref: ref);
                      },
                      iconSize: 25,
                      profileIconSize: 15,
                      wideScreenIconSize: 25,
                      wideScreenProfileIconSize: 15,
                      appWebChannel: appWebChannel,
                      appStorage: appStorage,
                      appCacheData: appCacheData,
                      onUserRemoved: () {
                        onUserRemoved(ref);
                      },
                      onUserAdded: () {
                        onUserAdded(ref);
                      },
                      onUsernameChanged: () {
                        onUsernameChanged(ref);
                      },
                      onSelectedUserChanged: (user) {
                        onSelectedUserChanged(user, ref);
                      },
                      setAndroidNavigationBarColor: () {
                        appMethodChannel.setNavigationBarColor(Theme
                            .of(context)
                            .scaffoldBackgroundColor);
                      },
                    )
                  ],
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DragTarget<Set<String>>(
                        onAcceptWithDetails: (details) {
                          if(fragmentIndex == FragmentIndex.trash) {
                            restoreSelectedFiles(ref: ref, selectedIds: details.data, desktopListviewController: desktopListviewController);
                          }
                          else {
                            moveSelectedFiles(selectedIds: details.data,
                                oldParentId: currentFolderId,
                                ref: ref,
                                parent: FileModel(id: ""),
                                files: files);
                          }
                        },
                        builder:
                            (context, candidateData, rejectedData) =>
                            _MenuItem(
                              icon: Icons.home,
                              title: AppLocalizations.of(context).get("home"),
                              onPressed: () {
                                if (ref.read(selectedFilesProvider) != null) {
                                  ref.read(selectedFilesProvider.notifier).endSelection();
                                }
                                ref.read(fragmentIndexProvider.notifier).setIndex(FragmentIndex.files);
                              },
                            ),
                      ),
                      DragTarget<Set<String>>(
                          onAcceptWithDetails: (details) {
                            moveSelectedFilesToTrash(ref: ref, selectedIds: details.data, desktopListviewController: desktopListviewController);
                          },
                          builder: (context, candidateData, rejectedData) => _MenuItem(
                        icon: Icons.delete,
                        title: AppLocalizations.of(context).get("@trash"),
                        onPressed: () {
                          if (ref.read(selectedFilesProvider) != null) {
                            ref.read(selectedFilesProvider.notifier).endSelection();
                          }
                          ref.read(fragmentIndexProvider.notifier).setIndex(FragmentIndex.trash);
                        },
                      )),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder:
                              (context) =>
                              Dialog(
                                child: SizedBox(
                                  width: 450,
                                  height: 500,
                                  child: Column(
                                    children: [
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: IconButton(
                                          onPressed: () {
                                            appSettings.save();
                                            Navigator.pop(context);
                                          },
                                          icon: const Icon(Icons.cancel_outlined),
                                        ),
                                      ),
                                      const Expanded(child: SettingsView()),
                                    ],
                                  ),
                                ),
                              ),
                        ).then((value) {
                          appSettings.save();
                        });
                      },
                      icon: const Icon(Icons.settings, size: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            top: 0,
            child: MouseRegion(
              cursor: SystemMouseCursors.resizeColumn,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onDoubleTap: () {
                  ref.read(sidebarWidthProvider.notifier).set(200);
                  appCacheData.sidebarWidth = defaultSidebarWidth;
                  appCacheData.save();
                },
                onHorizontalDragUpdate: (d) {
                  ref.read(sidebarWidthProvider.notifier).set(width + d.delta.dx);
                },
                onHorizontalDragEnd: (d) {
                  appCacheData.sidebarWidth = width;
                  appCacheData.save();
                },
                child: SizedBox(
                  width: 5,
                  child: VerticalDivider(
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final void Function() onPressed;

  const _MenuItem({required this.icon, required this.title, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        mouseCursor: SystemMouseCursors.basic,
        borderRadius: BorderRadius.circular(10),
        highlightColor: Theme
            .of(context)
            .dividerColor,
        onTap: () {
          onPressed();
          if (isDesktop()) {
            appCacheData.windowHeight = appWindow.size.height;
            appCacheData.windowWidth = appWindow.size.width;
          }
          appCacheData.save();
        },
        child: Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(padding: const EdgeInsets.only(left: 18.0, right: 8), child: Icon(icon, size: 18, color: Theme.of(context).highlightColor)),
              Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
            ],
          ),
        ),
      ),
    );
  }
}