import 'package:cloud/models/file_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../channels/app_web_channel.dart';
import '../models/app_cache.dart';
import '../models/sort_option.dart';

class FilesState {
  final Map<String, FileModel> files;
  final Map<String, List<String>> idLists;
  final List<String> trash;

  FilesState(this.files, this.idLists, this.trash);

  List<String> idListByDirectoryId(String id, {String? filename}) {
    if(filename == null) {
      return idLists[id] ?? [];
    }
    var list = idLists[id] ?? [];
    return list.where((id) => files[id]?.name.toLowerCase().contains(filename.toLowerCase()) ?? false).toList();
  }

  List<String> getTrash({String? searchKeyword}) {
    if(searchKeyword == null) {
      return trash;
    }
    return trash.where((id) => files[id]?.name.toLowerCase().contains(searchKeyword.toLowerCase()) ?? false).toList();
  }

}

class FilesNotifier extends Notifier<FilesState> {

  @override
  FilesState build() {
    return FilesState({}, {}, []);
  }

  void insertFile(FileModel fileModel) {
    final files = {...state.files, fileModel.id: fileModel};
    // final idList = state.idLists[fileModel.id].contains(fileModel.id) ? [...state.idLists] : [...state.idLists, fileModel.id];

    final list = state.idLists.putIfAbsent(fileModel.parentId, () => []);
    final mergedList = list.contains(fileModel.id) ? [...list] : [...list, fileModel.id];

    final idLists = {...state.idLists, fileModel.parentId: mergedList};
    final sortOptionId = fileModel.parentId.isEmpty ? "!FILES" : fileModel.parentId;
    idLists[fileModel.parentId]!.sortFiles(appCacheData.sortOption(sortOptionId), files);
    state = FilesState(files, idLists, [...state.trash]);
  }

  void moveFilesToTrash(String folderId, List<String> list) {
    final idList = state.idLists.putIfAbsent(folderId, () => []).where((id) => !list.contains(id)).toList();
    final idLists = {...state.idLists, folderId: idList};
    final trash = [
      ...state.trash,
      ...list.where((id) => !state.trash.contains(id)),
    ];
    final files = {...state.files};
    trash.sortFiles(appCacheData.sortOption("!TRASH"), files);
    state = FilesState(files, idLists, trash);
  }

  void moveFiles(List<String> selected, String from, String to) {
    final fromList = state.idLists.putIfAbsent(from, () => []).where((id) => !selected.contains(id)).toList();
    final toList = [...state.idLists.putIfAbsent(to, () => []), ...selected];

    final idLists = {...state.idLists, from: fromList, to: toList};
    final trash = [...state.trash];
    final files = {...state.files};

    final sortOptionIdFrom = from.isEmpty ? "!FILES" : from;
    final sortOptionIdTo = to.isEmpty ? "!FILES" : to;

    idLists[from]!.sortFiles(appCacheData.sortOption(sortOptionIdFrom), files);
    idLists[sortOptionIdTo]!.sortFiles(appCacheData.sortOption(sortOptionIdFrom), files);

    state = FilesState(files, idLists, trash);
  }

  void restoreFiles(List<String> list) {

    final idLists = {...state.idLists};
    idLists[""]!.addAll(list);

    final trash = state.trash.where((id) => !list.contains(id)).toList();
    final files = {...state.files};
    idLists[""]!.sortFiles(appCacheData.sortOption("!FILES"), files);
    state = FilesState(files, idLists, trash);
  }

  void deleteFiles(List<String> list) {
    final files = {...state.files}..removeWhere((key, value) => list.contains(key));
    final idList = {...state.idLists};
    final trash = state.trash.where((id) => !list.contains(id)).toList();
    state = FilesState(files, idList, trash);
  }

  void clear() {
    state = FilesState({}, {}, []);
  }

  void sortFiles(String? folderId) {
    final idList = state.idLists.putIfAbsent(folderId ?? "", () => []);
    idList.sortFiles(appCacheData.sortOption(folderId ?? "!FILES"), state.files);

    final idLists = {...state.idLists, folderId ?? "": idList};

    state = FilesState({...state.files}, idLists, [...state.trash]);
  }

  void sortTrash() {
    final trash = [...state.trash];
    trash.sortFiles(appCacheData.sortOption("!TRASH"), state.files);
    state = FilesState({...state.files}, {...state.idLists}, trash);
  }

  void init() {
    appWebChannel.getFiles(onSuccess: (list) {
      final Map<String, FileModel> files = {};
      final Map<String, List<String>> idLists = {};
      final List<String> trash = [];
      for(var item in list) {
        files[item.id] = item;
        if(item.deleted != null) {
          trash.add(item.id);
        }
        else {
          idLists.putIfAbsent(item.parentId, () => []).add(item.id);
        }
      }
      idLists.forEach((key, value) {
        if(key.isEmpty) {
          idLists[key]!.sortFiles(appCacheData.sortOption("!FILES"), files);
        }
        else {
          idLists[key]!.sortFiles(appCacheData.sortOption(key), files);
        }
      });

      state = FilesState(files, idLists, trash);
    }, onFailed: (code) {
    });
  }

}

final filesProvider = NotifierProvider<FilesNotifier, FilesState>(FilesNotifier.new);

extension FileModelNullSafeExtension on Map<String, FileModel> {
  FileModel get(String id) {
    return this[id] ?? FileModel(id: id);
  }
}

extension SortEx on List {
  void sortFiles(String sortOption, Map<String, FileModel> map) {
    switch(sortOption) {
      case SortOption.created:
        sort((a, b) {
          return map.get(a).created.compareTo(map.get(b).created);
        });
        break;
      case SortOption.modified:
        sort((a, b) {
          return map.get(a).modified.compareTo(map.get(b).modified);
        });
        break;
      case SortOption.uploaded:
        sort((a, b) {
          return map.get(a).uploaded.compareTo(map.get(b).uploaded);
        });
        break;
      case SortOption.deleted:
        sort((a, b) {
          return map.get(a).deleted!.compareTo(map.get(b).deleted!);
        });
        break;
      case SortOption.name:
        sort((a, b) {
          return map.get(a).name.toLowerCase().compareTo(map.get(b).name.toLowerCase());
        });
        break;
      case SortOption.size:
        sort((a, b) {
          return map.get(a).size.compareTo(map.get(b).size);
        });
        break;
      case SortOption.createdDescending:
        sort((a, b) {
          return map.get(b).created.compareTo(map.get(a).created);
        });
        break;
      case SortOption.modifiedDescending:
        sort((a, b) {
          return map.get(b).modified.compareTo(map.get(a).modified);
        });
        break;
      case SortOption.uploadedDescending:
        sort((a, b) {
          return map.get(b).uploaded.compareTo(map.get(a).uploaded);
        });
        break;
      case SortOption.deletedDescending:
        sort((a, b) {
          return map.get(b).deleted!.compareTo(map.get(a).deleted!);
        });
        break;
      case SortOption.nameDescending:
        sort((a, b) {
          return map.get(b).name.toLowerCase().compareTo(map.get(a).name.toLowerCase());
        });
        break;
      case SortOption.sizeDescending:
        sort((a, b) {
          return map.get(b).size.compareTo(map.get(a).size);
        });
        break;
    }
  }
}