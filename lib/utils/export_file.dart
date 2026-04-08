import 'dart:io';

import 'package:amphi/models/app_localizations.dart';
import 'package:cloud/models/file_model.dart';
import 'package:cloud/models/transfer_state.dart';
import 'package:cloud/providers/transfers_provider.dart';
import 'package:cloud/utils/toast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../channels/app_web_channel.dart';

Future<void> exportFile({required FileModel fileModel, required BuildContext context, required WidgetRef ref}) async {
    if(fileModel.isAvailableOffline) {
      final file = File(fileModel.offlinePath);
      await FilePicker.platform.saveFile(
          fileName: fileModel.name,
          bytes: await file.readAsBytes()
      );

      if(context.mounted) {
        showToast(context, AppLocalizations.of(context).get("export_successful"));
      }
    }
    else {
      appWebChannel.downloadFileFromCloud(id: fileModel.id, filePath: fileModel.temporaryPath, onSuccess: () async {
        ref.read(transfersProvider.notifier).removeItem(fileModel.id);

        final file = File(fileModel.temporaryPath);
        await FilePicker.platform.saveFile(
            fileName: fileModel.name,
            bytes: await file.readAsBytes()
        );

        if(context.mounted) {
          showToast(context, AppLocalizations.of(context).get("export_successful"));
        }
      }, onProgress: (transferred, total) {
        ref.read(transfersProvider.notifier).insertItem(TransferState(fileId: fileModel.id, transferredBytes: transferred, totalBytes: total));
      });

    }
}