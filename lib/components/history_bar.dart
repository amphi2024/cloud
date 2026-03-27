import 'dart:io';

import 'package:amphi/models/app_localizations.dart';
import 'package:cloud/providers/files_provider.dart';
import 'package:cloud/providers/providers.dart';
import 'package:cloud/utils/move_files.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/file_model.dart';
import '../providers/desktop_listview_controller_provider.dart';

class HistoryBar extends ConsumerWidget {
  const HistoryBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSearching = ref.watch(searchKeywordProvider) != null;

    return Container(
      width: MediaQuery
          .of(context)
          .size
          .width - 500 - (Platform.isWindows ? 100 : 0),
      height: 40,
      decoration: BoxDecoration(
          color: Theme
              .of(context)
              .navigationDrawerTheme
              .backgroundColor,
          borderRadius: BorderRadius.circular(10)
      ),
      child: isSearching ? _Search() : _History(),
    );
  }
}

class _Search extends ConsumerWidget {
  const _Search();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: TextField(
        onChanged: (text) {
          ref.read(searchKeywordProvider.notifier).setKeyword(text);
        },
        onTapOutside: (event) {
          ref.read(searchKeywordProvider.notifier).endSearch();
        },
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context).get("hint_search_files"),
          enabledBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }
}

class _History extends ConsumerWidget {
  const _History();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Widget> children = [];
    final history = ref.watch(historyProvider);

    children.add(_Home());

    for (int i = 1; i < ref
        .watch(historyProvider)
        .length; i++) {
      children.add(
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text("/"),
          )
      );
      children.add(_Item(folder: history[i], index: i));
    }
    return Row(
      children: children,
    );
  }
}

class _Home extends ConsumerWidget {
  const _Home();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFolderId = ref.watch(historyProvider.notifier).currentFolder().id;
    final controller = ref.watch(desktopListviewControllerProvider);
    final files = ref.watch(filesProvider).files;
    return DragTarget<Set<String>>(
        onAcceptWithDetails: (details) {
          moveSelectedFiles(selectedIds: details.data, oldParentId: currentFolderId, ref: ref, parent: FileModel(id: ""), files: files, desktopListviewController: controller);
        },
        builder: (context, candidateData, rejectedData) {
          return Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              highlightColor: Theme
                  .of(context)
                  .highlightColor
                  .withAlpha(100),
              mouseCursor: SystemMouseCursors.basic,
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                ref.read(historyProvider.notifier).clear();
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Icon(Icons.home, color: Theme
                        .of(context)
                        .textTheme
                        .bodyMedium
                        ?.color),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        AppLocalizations.of(context).get("home"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}


class _Item extends ConsumerWidget {

  final int index;
  final FileModel folder;
  const _Item({required this.folder, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFolderId = ref.watch(historyProvider.notifier).currentFolder().id;
    final controller = ref.watch(desktopListviewControllerProvider);
    final files = ref.watch(filesProvider).files;
    return DragTarget<Set<String>>(
        onAcceptWithDetails: (details) {
          moveSelectedFiles(selectedIds: details.data, oldParentId: currentFolderId, ref: ref, parent: folder, files: files, desktopListviewController: controller);
        },
        builder: (context, candidateData, rejectedData) {
      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          highlightColor: Theme
              .of(context)
              .highlightColor
              .withAlpha(100),
          mouseCursor: SystemMouseCursors.basic,
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            ref.read(historyProvider.notifier).popIndex(index);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(folder.name),
          ),
        ),
      );
    });
  }
}
