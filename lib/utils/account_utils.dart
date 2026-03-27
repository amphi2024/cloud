import 'package:amphi/models/user.dart';
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
  ref.read(filesProvider.notifier).init();
}

void onUserAdded(WidgetRef ref) async {
  appWebChannel.disconnectWebSocket();
  appStorage.initPaths();
  await appSettings.getData();

}

void onUsernameChanged(WidgetRef ref) {

}

void onSelectedUserChanged(User user, WidgetRef ref) async {
  appWebChannel.disconnectWebSocket();
  appStorage.initPaths();
  await appSettings.getData();
  appWebChannel.connectWebSocket();

  ref.read(filesProvider.notifier).init();
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
  ref.read(filesProvider.notifier).init();
}