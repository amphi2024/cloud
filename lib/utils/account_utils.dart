import 'package:amphi/models/user.dart';
import 'package:cloud/database/database_helper.dart';
import 'package:cloud/providers/csd_themes_provider.dart';
import 'package:cloud/providers/files_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../channels/app_web_channel.dart';
import '../models/app_settings.dart';
import '../models/app_storage.dart';

void onUserRemoved(WidgetRef ref) async {
  appWebChannel.disconnectWebSocket();
  appStorage.initPaths();
  await appSettings.getData();
  appWebChannel.connectWebSocket();
  await databaseHelper.notifySelectedUserChanged();
  ref.read(filesProvider.notifier).rebuild();
  ref.read(csdThemesProvider.notifier).rebuild();
}

void onUserAdded(WidgetRef ref) async {
  appWebChannel.disconnectWebSocket();
  appStorage.initPaths();
  await appSettings.getData();
  await databaseHelper.notifySelectedUserChanged();
  ref.read(filesProvider.notifier).rebuild();
  ref.read(csdThemesProvider.notifier).rebuild();
}

void onUsernameChanged(WidgetRef ref) {

}

void onSelectedUserChanged(User user, WidgetRef ref) async {
  appWebChannel.disconnectWebSocket();
  appStorage.initPaths();
  await appSettings.getData();
  appWebChannel.connectWebSocket();

  await databaseHelper.notifySelectedUserChanged();
  ref.read(filesProvider.notifier).rebuild();
  ref.read(csdThemesProvider.notifier).rebuild();
}

void onLoggedIn({required String id, required String token, required String username, required BuildContext context,required WidgetRef ref}) async {
  appStorage.selectedUser.id = id;
  Navigator.popUntil(
    context,
        (Route<dynamic> route) => route.isFirst,
  );
  appStorage.selectedUser.name = username;
  appStorage.selectedUser.token = token;
  await appStorage.saveSelectedUserInformation();
  await databaseHelper.notifySelectedUserChanged();
  ref.read(filesProvider.notifier).rebuild();
  ref.read(csdThemesProvider.notifier).rebuild();
}