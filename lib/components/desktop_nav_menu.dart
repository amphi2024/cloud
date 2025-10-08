import 'package:amphi/models/app.dart';
import 'package:amphi/models/app_localizations.dart';
import 'package:amphi/widgets/account/account_button.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:cloud/dialogs/edit_filename_dialog.dart';
import 'package:cloud/utils/file_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../channels/app_method_channel.dart';
import '../channels/app_web_channel.dart';
import '../models/app_cache.dart';
import '../models/app_settings.dart';
import '../models/app_storage.dart';
import '../models/fragment_index.dart';
import '../providers/providers.dart';
import '../utils/account_utils.dart';
import '../views/settings_view.dart';

class DesktopNavMenu extends StatelessWidget {

  final WidgetRef ref;
  const DesktopNavMenu({super.key, required this.ref});

  @override
  Widget build(BuildContext context) {
    final currentFolderId = ref.read(historyProvider.notifier).currentFolder().id;

    return Container(
        width: 200,
        color: Theme.of(context).navigationDrawerTheme.backgroundColor,
        child: Padding(
          padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Builder(builder: (context) {
                    if (App.isDesktop()) {
                      return SizedBox(height: 50, child: MoveWindow());
                    } else {
                      return const SizedBox(height: 50);
                    }
                  })),
                  AccountButton(onLoggedIn: ({required id, required token, required username}) {
                  onLoggedIn(id: id, token: token, username: username, context: context, ref: ref);
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
                  appMethodChannel.setNavigationBarColor(Theme.of(context).scaffoldBackgroundColor);
                  }),
                  IconButton(
                      onPressed: () {
                        appStorage.refreshDataWithServer(ref);
                      },
                      icon: const Icon(Icons.refresh))
                ],
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MenuItem(icon: Icons.home, title: AppLocalizations.of(context).get("home"), onPressed: () {
                      if(ref.read(selectedFilesProvider) != null) {
                        ref.read(selectedFilesProvider.notifier).endSelection();
                      }
                      ref.read(fragmentIndexProvider.notifier).setIndex(FragmentIndex.files);
                    }),
                    _MenuItem(icon: Icons.delete, title: AppLocalizations.of(context).get("@trash"), onPressed: () {
                      if(ref.read(selectedFilesProvider) != null) {
                        ref.read(selectedFilesProvider.notifier).endSelection();
                      }
                      ref.read(fragmentIndexProvider.notifier).setIndex(FragmentIndex.trash);
                    }),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) => Dialog(
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
                                          icon: const Icon(Icons.cancel_outlined)),
                                    ),
                                    const Expanded(child: SettingsView()),
                                  ],
                                ),
                              ),
                            )).then((value) {
                          appSettings.save();
                        });
                      },
                      icon: const Icon(
                        Icons.settings,
                        size: 18,
                      )),
                  PopupMenuButton(
                      itemBuilder: (context) {
                        return [
                          PopupMenuItem(
                            height: 30,
                            onTap: () {
                              pickFilesAndUpload(currentFolderId: currentFolderId, ref: ref, context: context);
                            },
                            child: Text(AppLocalizations.of(context).get("file")),
                          ),
                          PopupMenuItem(
                            height: 30,
                            onTap: () {
                              showDialog(context: context, builder: (context) {
                                return EditFilenameDialog(initialValue: "", onSave: (folderName) {
                                  createFolder(folderName: folderName, parentFolderId: currentFolderId, ref: ref, context: context);
                                });
                              });
                            },
                            child: Text(AppLocalizations.of(context).get("folder")),
                          ),
                        ];
                      },
                      icon: const Icon(
                        Icons.add_circle_outline,
                        size: 18,
                      )),
                  // const TransfersButton(iconSize: 18)
                ],
              )
            ],
          ),
        ));
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final void Function() onPressed;

  const _MenuItem({required this.icon, required this.title, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 6),
      child: GestureDetector(
        onTap: () {
          onPressed();
          if(App.isDesktop()) {
            appCacheData.windowHeight = appWindow.size.height;
            appCacheData.windowWidth = appWindow.size.width;
          }
          appCacheData.save();
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 18.0, right: 8),
              child: Icon(
                icon,
                size: 18,
              ),
            ),
            Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 16),
                )),
          ],
        ),
      ),
    );
  }
}