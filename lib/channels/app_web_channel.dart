import 'dart:convert';
import 'dart:io';

import 'package:amphi/models/app_web_channel_core.dart';
import 'package:amphi/models/update_event.dart';
import 'package:cloud/models/file_model.dart';
import 'package:http/http.dart';
import 'package:web_socket_channel/io.dart';

import '../models/app_settings.dart';
import '../models/app_storage.dart';

final appWebChannel = AppWebChannel.getInstance();

class AppWebChannel extends AppWebChannelCore {
  static final AppWebChannel _instance = AppWebChannel._internal();

  AppWebChannel._internal();

  static AppWebChannel getInstance() => _instance;

  @override
  String get serverAddress => appSettings.serverAddress;

  @override
  String get appType => "cloud";

  @override
  String get token => appStorage.selectedUser.token;

  static const int failedToConnect = -1;
  static const int failedToAuth = -2;

  late void Function(UpdateEvent) onWebSocketEvent;

  @override
  void setupWebsocketChannel(String serverAddress) async {
    webSocketChannel = IOWebSocketChannel.connect(serverAddress, headers: {"Authorization": appStorage.selectedUser.token});

    webSocketChannel?.stream.listen((message) async {
      Map<String, dynamic> jsonData = jsonDecode(message);
      UpdateEvent updateEvent = UpdateEvent.fromJson(jsonData);
      onWebSocketEvent(updateEvent);

    }, onDone: () {
      connected = false;
    }, onError: (d) {
      connected = false;
    }, cancelOnError: true);
  }

  void getEvents({required void Function(List<UpdateEvent>) onResponse}) async {
    List<UpdateEvent> list = [];
    final response = await get(
      Uri.parse("$serverAddress/cloud/events"),
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', "Authorization": appWebChannel.token},
    );
    if (response.statusCode == HttpStatus.ok) {
      List<dynamic> decoded = jsonDecode(utf8.decode(response.bodyBytes));
      for (Map<String, dynamic> map in decoded) {
        UpdateEvent updateEvent = UpdateEvent.fromJson(map);
        list.add(updateEvent);
      }
      onResponse(list);
    } else if (response.statusCode == HttpStatus.unauthorized) {
      appStorage.selectedUser.token = "";
    }
  }

  void acknowledgeEvent(UpdateEvent updateEvent) async {
    Map<String, dynamic> data = {
      'value': updateEvent.value,
      'action': updateEvent.action,
    };

    String postData = json.encode(data);

    await delete(
      Uri.parse("${appSettings.serverAddress}/cloud/events"),
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', "Authorization": appStorage.selectedUser.token},
      body: postData,
    );
  }

  Future<void> getFiles({required void Function(List<FileModel>) onSuccess, void Function(int?)? onFailed}) async {
    try {
      final response = await get(
        Uri.parse("$serverAddress/cloud/files"),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', "Authorization": appWebChannel.token},
      );
      if (response.statusCode == 200) {
        List<dynamic> list = jsonDecode(response.body);
        List<FileModel> items = [];
        for(var item in list) {
          try {
            if(item is Map<String, dynamic>) {
              final fileModel = FileModel(id: item["id"], data: item);
              items.add(fileModel);
            }
          }
          catch(e) {
            final fileModel = FileModel(id: "");
            items.add(fileModel);
          }

        }
        onSuccess(items);
      } else {
        if (onFailed != null) {
          onFailed(response.statusCode);
        }
      }
    } catch (e) {
      if (onFailed != null) {
        onFailed(null);
      }
    }
  }

  Future<void> getItems({required String url, required void Function(List<String>) onSuccess, void Function(int?)? onFailed}) async {
    try {
      final response = await get(
        Uri.parse(url),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', "Authorization": appWebChannel.token},
      );
      if (response.statusCode == 200) {
        List<dynamic> list = jsonDecode(response.body);
        onSuccess(list.map((item) => item as String).toList());
      } else {
        if (onFailed != null) {
          onFailed(response.statusCode);
        }
      }
    } catch (e) {
      if (onFailed != null) {
        onFailed(null);
      }
    }
  }

  Future<void> createFile({required Map<String, dynamic> data, required void Function(String id) onSuccess, void Function(int?)? onFailed}) async {
    try {
      final response = await post(Uri.parse("$serverAddress/cloud/files"),
          headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8', "Authorization": token}, body: jsonEncode(data));
      if (response.statusCode == 200) {
        final id = response.body;
          onSuccess(id);
        final updateEvent = UpdateEvent(action: "create_file", value: id);
        postWebSocketMessage(updateEvent.toWebSocketMessage());
      } else {
        if (onFailed != null) {
          onFailed(response.statusCode);
        }
      }
    } catch (e) {
      if (onFailed != null) {
        onFailed(null);
      }
    }
  }

  Future<void> uploadFileToCloud({required String id, required String filePath, void Function()? onSuccess, void Function(int?)? onFailed, void Function(int sent, int total)? onProgress}) async {
    await postFile(url: "$serverAddress/cloud/files/$id/upload", filePath: filePath, onSuccess: onSuccess, onFailed: onFailed, onProgress: onProgress);
  }

  Future<void> downloadFileFromCloud({required String id, required void Function(List<int>) onSuccess, void Function(int?)? onFailed, void Function(int, int)? onProgress}) async {
    try {
      final request = Request('GET', Uri.parse("$serverAddress/cloud/files/$id/download"));
      request.headers.addAll({
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": token,
      });

      final response = await Client().send(request);
      List<int> data = [];
      final contentLength = response.contentLength ?? 0;

      response.stream.listen(
            (chunk) {
              data.addAll(chunk);
          if (onProgress != null && contentLength != 0) {
            onProgress(chunk.length, contentLength);
          }
        },
        onDone: () async {
          if (response.statusCode == 200) {
            onSuccess(data);
          }
          else {
            onFailed?.call(response.statusCode);
          }
        },
        onError: (e) async {
          onFailed?.call(null);
        },
        cancelOnError: true,
      );
    } catch (e) {
      onFailed?.call(null);
    }
  }

  Future<void> updateFileInfo({required FileModel fileModel, void Function()? onSuccess, void Function(int?)? onFailed}) async {
    final updateEvent = UpdateEvent(action: "update_file_info", value: fileModel.id);
    await patchJson(url: "$serverAddress/cloud/files/${fileModel.id}", jsonBody: jsonEncode(fileModel.data), updateEvent: updateEvent, onSuccess: onSuccess, onFailed: onFailed);
  }

  Future<void> deleteFile({required String id, void Function()? onSuccess, void Function(int?)? onFailed}) async {
    final updateEvent = UpdateEvent(action: "delete_file", value: id);
    await simpleDelete(url: "$serverAddress/cloud/files/$id", updateEvent: updateEvent);
  }
}
