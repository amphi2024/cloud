import 'dart:io';

import 'package:amphi/models/app_localizations.dart';
import 'package:cloud/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: isSearching? _Search() : _History(),
      ),
    );
  }
}

class _Search extends ConsumerWidget {
  const _Search();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
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
    );
  }
}

class _History extends ConsumerWidget {
  const _History();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Widget> children = [];

    children.add(GestureDetector(
      onTap: () {
        ref.read(historyProvider.notifier).clear();
      },
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
    ));

    for (int i = 1; i < ref
        .watch(historyProvider)
        .length; i++) {
      children.add(
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text("/"),
          )
      );
      children.add(
          GestureDetector(
            onTap: () {
              ref.read(historyProvider.notifier).popIndex(i);
            },
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(ref.read(historyProvider)[i].name),
            ),
          )
      );
    }
    return Row(
      children: children,
    );
  }
}