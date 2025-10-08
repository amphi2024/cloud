import 'package:cloud/components/file_thumbnail.dart';
import 'package:cloud/models/file_model.dart';
import 'package:cloud/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FileGridItem extends ConsumerWidget {
  final void Function() onPressed;
  final FileModel fileModel;
  final bool? hideCheckbox;
  const FileGridItem({super.key, required this.fileModel, required this.onPressed, this.hideCheckbox});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onPressed,
      onLongPress: () {
        if (ref.watch(selectedFilesProvider) == null) {
          ref.read(selectedFilesProvider.notifier).startSelection();
        }
      },
      child: Stack(
        children: [
          Center(
            child: Column(
              children: [
                FileThumbnail(fileModel: fileModel, iconSize: 100, fit: BoxFit.cover),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8, top: 15, bottom: 15),
                  child: Text(fileModel.name, softWrap: true, maxLines: 3, textAlign: TextAlign.center),
                ),
              ],
            ),
          ),
          Positioned(
            left: 8,
            top: 8,
            child: IgnorePointer(
              ignoring: ref.watch(selectedFilesProvider) == null && hideCheckbox == true,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 750),
                curve: Curves.easeOutQuint,
                opacity: ref.watch(selectedFilesProvider) != null && hideCheckbox == null ? 1 : 0,
                child: Checkbox(
                  value: ref.read(selectedFilesProvider)?.contains(fileModel.id) ?? false,
                  onChanged: (value) {
                    if (ref.read(selectedFilesProvider)?.contains(fileModel.id) == true) {
                      ref.read(selectedFilesProvider.notifier).removeId(fileModel.id);
                    } else {
                      ref.read(selectedFilesProvider.notifier).addId(fileModel.id);
                    }
                  },
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
