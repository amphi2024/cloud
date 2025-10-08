import 'package:amphi/models/app_storage_core.dart';
import 'package:amphi/models/update_event.dart';
import 'package:amphi/utils/path_utils.dart';
import 'package:cloud/models/file_model.dart';
import 'package:cloud/providers/files_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../channels/app_web_channel.dart';


final appStorage = AppStorage.getInstance();

class AppStorage extends AppStorageCore {
  static final AppStorage _instance = AppStorage._internal();
  AppStorage._internal();

  late String themesPath;
  static AppStorage getInstance() => _instance;

  @override
  void initPaths() {
    super.initPaths();
    themesPath = PathUtils.join(selectedUser.storagePath, "themes");

    createDirectoryIfNotExists(themesPath);
  }

  Future<void> syncDataFromEvents(WidgetRef ref) async {
    if (appWebChannel.token.isNotEmpty) {
      appWebChannel.getEvents(onResponse: (updateEvents) async {
        for (UpdateEvent updateEvent in updateEvents) {
          syncData(updateEvent, ref);
        }
      });
    }
  }

  Future<void> syncData(UpdateEvent updateEvent, WidgetRef ref) async {
    final value = updateEvent.value;

    switch (updateEvent.action) {
      case "create_file":
        appWebChannel.downloadJson(url: "${appWebChannel.serverAddress}/cloud/files/$value", onSuccess: (data) {
          var fileModel = FileModel(id: value, data: data);
          ref.read(filesProvider.notifier).insertFile(fileModel);
        });
        break;
    }

    appWebChannel.acknowledgeEvent(updateEvent);
  }

  void refreshDataWithServer(WidgetRef ref) async {
    ref.read(filesProvider.notifier).init();
  }

}