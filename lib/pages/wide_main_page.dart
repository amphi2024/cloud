import 'dart:io';

import 'package:amphi/models/app.dart';
import 'package:amphi/models/app_localizations.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:cloud/components/content/file_content.dart';
import 'package:cloud/components/history_bar.dart';
import 'package:cloud/components/main_page_app_bar.dart';
import 'package:cloud/models/file_model.dart';
import 'package:cloud/models/fragment_index.dart';
import 'package:cloud/providers/files_provider.dart';
import 'package:cloud/providers/providers.dart';
import 'package:cloud/views/files_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../channels/app_method_channel.dart';
import '../components/custom_window_button.dart';
import '../components/desktop_nav_menu.dart';

const double desktopTitleBarHeight = 50;

class WideMainPage extends ConsumerWidget {
  const WideMainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    appMethodChannel.setNavigationBarColor(Theme.of(context).scaffoldBackgroundColor);
    final fragmentIndex = ref.watch(fragmentIndexProvider);
    final showingFile = ref.watch(showingFileProvider);
    double showingFileWidth = MediaQuery.of(context).size.width - 450;
    final currentFolder =
        ref.watch(historyProvider).lastOrNull ?? FileModel(id: "");
    final selectedItems = ref.watch(selectedFilesProvider);
    final actions = appbarActions(
      context: context,
      fragmentIndex: fragmentIndex,
      currentFolder: currentFolder,
      selectedItems: selectedItems,
      ref: ref,
      showingFile: showingFile
    );

    final colors = CustomWindowButtonColors(
      iconMouseOver: Theme.of(context).textTheme.bodyMedium?.color,
      mouseOver: const Color.fromRGBO(125, 125, 125, 0.1),
      iconNormal: Theme.of(context).textTheme.bodyMedium?.color,
      mouseDown: const Color.fromRGBO(125, 125, 125, 0.1),
      iconMouseDown: Theme.of(context).textTheme.bodyMedium?.color,
      normal: Theme.of(context).scaffoldBackgroundColor,
    );

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: DesktopNavMenu(ref: ref),
          ),
          Positioned(
            left: 200,
            top: MediaQuery.of(context).padding.top,
            right: 0,
            child: SizedBox(
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
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        color:
                            ref.read(historyProvider).length > 1
                                ? null
                                : Theme.of(context).disabledColor,
                      ),
                    ),
                  ),
                  if (Platform.isWindows || Platform.isMacOS)
                    Expanded(
                      child: SizedBox(
                        height: desktopTitleBarHeight,
                        child: MoveWindow(),
                      ),
                    ),
                  HistoryBar(),
                  if (Platform.isWindows || Platform.isMacOS)
                    Expanded(
                      child: SizedBox(
                        height: desktopTitleBarHeight,
                        child: MoveWindow(),
                      ),
                    ),
                  Row(
                    children: [
                      ...actions,
                      if (Platform.isWindows) ...[
                        Visibility(
                          visible: App.isDesktop(),
                          child: MinimizeCustomWindowButton(colors: colors),
                        ),
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
                            iconNormal: const Color(0xFF805306),
                            iconMouseOver: const Color(0xFFFFFFFF),
                            normal: Theme.of(context).scaffoldBackgroundColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 200,
            right: showingFile == null ? 0 : showingFileWidth,
            bottom: 0,
            top: desktopTitleBarHeight + MediaQuery.of(context).padding.top,
            child: () {
              switch (fragmentIndex) {
                case FragmentIndex.trash:
                  return FilesGridView(
                    files: ref.watch(filesProvider).getTrash(searchKeyword: ref.watch(searchKeywordProvider)),
                    placeholder: AppLocalizations.of(context).get("no_files_in_trash"),
                  );
                default:
                  return FilesGridView(
                    files: ref
                        .watch(filesProvider)
                        .idListByDirectoryId(currentFolder.id, filename: ref.watch(searchKeywordProvider)),
                    placeholder: AppLocalizations.of(context).get("no_files"),
                  );
              }
            }(),
          ),
          if(showingFile != null) ...[
            Positioned(
                top: desktopTitleBarHeight + MediaQuery.of(context).padding.top,
                bottom: 0,
                right: 0,
                child: SizedBox(
                  width: showingFileWidth,
                  child: FileContent(fileModel: showingFile, iconSize: 100),
                ))
          ]
        ],
      ),
    );
  }
}
