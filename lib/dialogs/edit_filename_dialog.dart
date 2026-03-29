import 'package:amphi/models/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditFilenameDialog extends ConsumerStatefulWidget {

  final String initialValue;
  final void Function(String) onSave;
  const EditFilenameDialog({super.key, required this.initialValue, required this.onSave});

  @override
  ConsumerState<EditFilenameDialog> createState() => _EditFolderDialogState();
}

class _EditFolderDialogState extends ConsumerState<EditFilenameDialog> {

  late final controller = TextEditingController(text: widget.initialValue);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SizedBox(
        width: 250,
        height: 120,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                    hintText: AppLocalizations.of(context).get("name")
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(onPressed: () {
                  Navigator.pop(context);
                }, icon: Icon(Icons.cancel_outlined, size: 20,)),
                IconButton(onPressed: () {
                  widget.onSave(controller.text);
                  Navigator.pop(context);
                }, icon: Icon(Icons.check_circle_outline, size: 20,))
              ],
            )
          ],
        ),
      ),
    );
  }
}