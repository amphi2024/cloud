import 'dart:io';

import 'package:amphi/models/app_localizations.dart';
import 'package:amphi/widgets/account/account_button.dart';
import 'package:cloud/channels/app_method_channel.dart';
import 'package:cloud/components/floating_button.dart';
import 'package:cloud/components/labeled_floating_button.dart';
import 'package:cloud/components/main_page_app_bar.dart';
import 'package:cloud/components/rectangle_floating_button.dart';
import 'package:cloud/dialogs/edit_filename_dialog.dart';
import 'package:cloud/models/app_settings.dart';
import 'package:cloud/models/file_model.dart';
import 'package:cloud/models/fragment_index.dart';
import 'package:cloud/pages/settings_page.dart';
import 'package:cloud/pages/trash_page.dart';
import 'package:cloud/providers/files_provider.dart';
import 'package:cloud/providers/providers.dart';
import 'package:cloud/utils/account_utils.dart';
import 'package:cloud/utils/file_utils.dart';
import 'package:cloud/utils/toast.dart';
import 'package:cloud/views/files_grid_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../channels/app_web_channel.dart';
import '../models/app_cache.dart';
import '../models/app_storage.dart';

final _floatingButtonCurve = Curves.easeOutQuint;

class MainPage extends ConsumerStatefulWidget {

  final FileModel folder;
  const MainPage({super.key, required this.folder});

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends ConsumerState<MainPage> {

  bool searchBarShowing = false;
  final filenameController = TextEditingController();
  final focusNode = FocusNode();

  @override
  void dispose() {
    filenameController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    appMethodChannel.setNavigationBarColor(Theme.of(context).scaffoldBackgroundColor);
    final buttonRotated = ref.watch(buttonRotatedProvider);
    final currentFolderId = widget.folder.id;
    double bottomPadding = 15;
    final selectedFiles = ref.watch(selectedFilesProvider);

    if(Platform.isAndroid && !appSettings.transparentNavigationBar) {
      bottomPadding = MediaQuery.of(context).padding.bottom;
    }

    final actions = appbarActions(context: context, fragmentIndex: FragmentIndex.files, currentFolder: widget.folder, selectedItems: selectedFiles, ref: ref);

    return PopScope(
      canPop: selectedFiles == null && !searchBarShowing,
      onPopInvokedWithResult: (didPop, result) {
        if(selectedFiles != null) {
          ref.read(selectedFilesProvider.notifier).endSelection();
        }
        if(searchBarShowing) {
          filenameController.text = "";
          setState(() {
            searchBarShowing = false;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 60,
          leading: Builder(
            builder: (context) {
              return AccountButton(
                  onLoggedIn: ({required id, required token, required username}) {
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
                  });
            },
          ),
          title: Text(widget.folder.id.isEmpty ? AppLocalizations.of(context).get("files") : widget.folder.name),
          centerTitle: true,
          actions: actions,
        ),
        body: Stack(
          children: [
            AnimatedPositioned(
              left: 0,
              right: 0,
              top: searchBarShowing ? 0 : -60,
              curve: _floatingButtonCurve,
              duration: const Duration(milliseconds: 750),
              child: SizedBox(
                height: 50,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: filenameController,
                    focusNode: focusNode,
                    style: TextStyle(
                      fontSize: 14,
                    ),
                    onChanged: (text) {
                      setState(() {

                      });
                    },
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: AppLocalizations.of(context).get("hint_filename"),
                      contentPadding: EdgeInsets.only(right: 5),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(
                            color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.1),
                            style: BorderStyle.solid,
                            width: 1),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(
                            color: Theme.of(context).textTheme.bodyMedium!.color!.withValues(alpha: 0.1),
                            style: BorderStyle.solid,
                            width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            style: BorderStyle.solid,
                            width: 2),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            AnimatedPositioned(
              left: 0,
              right: 0,
              top: searchBarShowing ? 60 : 0,
              bottom: 0,
              curve: _floatingButtonCurve,
              duration: const Duration(milliseconds: 750),
              child: FilesGridView(
                files: ref.watch(filesProvider).idListByDirectoryId(widget.folder.id, filename: filenameController.text),
                placeholder: AppLocalizations.of(context).get("no_files"),
              ),
            ),
            AnimatedPositioned(
              left: 15,
              bottom: buttonRotated ? 15 + bottomPadding : -60,
              curve: _floatingButtonCurve,
              duration: Duration(milliseconds: buttonRotated ? 500 : 1500),
              child: RectangleFloatingButton(icon: Icons.settings, onPressed: () {
                Navigator.push(context, CupertinoPageRoute(builder: (context) => const SettingsPage()));
              }),
            ),
            AnimatedPositioned(
              left: 85,
              bottom: buttonRotated ? 15 + bottomPadding : -60,
              curve: _floatingButtonCurve,
              duration: Duration(milliseconds: buttonRotated ? 1000 : 1000),
              child: RectangleFloatingButton(icon: Icons.delete, onPressed: () {
                Navigator.push(context, CupertinoPageRoute(builder: (context) => const TrashPage()));
              }),
            ),
            AnimatedPositioned(
              left: 155,
              bottom: buttonRotated ? 15 + bottomPadding : -60,
              curve: _floatingButtonCurve,
              duration: Duration(milliseconds: buttonRotated ? 1500 : 500),
              child: RectangleFloatingButton(icon: Icons.search, onPressed: () {
                setState(() {
                  searchBarShowing = !searchBarShowing;
                });
                if(!searchBarShowing) {
                  focusNode.unfocus();
                  filenameController.text = "";
                }
              }),
            ),

            AnimatedPositioned(
              right: buttonRotated ? 15 : -200,
              bottom: 155 + bottomPadding,
              curve: _floatingButtonCurve,
              duration: Duration(milliseconds: buttonRotated ? 1250 : 1000),
              child: LabeledFloatingButton(label: AppLocalizations.of(context).get("folder"), icon: Icons.folder, onPressed: () {
                if(appSettings.serverAddress.isEmpty || appStorage.selectedUser.token.isEmpty) {
                  showToast(context, AppLocalizations.of(context).get("alert_login_required"));
                }
                else {
                  showDialog(context: context, builder: (context) {
                    return EditFilenameDialog(initialValue: "", onSave: (folderName) {
                      createFolder(folderName: folderName, parentFolderId: currentFolderId, ref: ref, context: context);
                    });
                  });
                }
              }),
            ),
            AnimatedPositioned(
              right: buttonRotated ? 15 : -200,
              bottom: 85 + bottomPadding,
              curve: _floatingButtonCurve,
              duration: Duration(milliseconds: buttonRotated ? 1000 : 1250),
              child: LabeledFloatingButton(label: AppLocalizations.of(context).get("file"), icon: Icons.file_copy, onPressed: () {
                if(appSettings.serverAddress.isEmpty || appStorage.selectedUser.token.isEmpty) {
                  showToast(context, AppLocalizations.of(context).get("alert_login_required"));
                }
                else {
                  pickFilesAndUpload(currentFolderId: currentFolderId, ref: ref, context: context);
                }
              }),
            ),
            Positioned(
              right: 15,
              bottom: 15 + bottomPadding,
              child: AnimatedRotation(
                turns: !buttonRotated ? 0 : -0.125,
                curve: _floatingButtonCurve,
                duration: const Duration(milliseconds: 750),
                child: FloatingButton(
                  icon: Icons.add,
                  onPressed: () {
                    ref.read(buttonRotatedProvider.notifier).toggle();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}