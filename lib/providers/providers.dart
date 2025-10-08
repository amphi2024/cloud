import 'package:cloud/models/file_model.dart';
import 'package:cloud/models/fragment_index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final buttonRotatedProvider =
NotifierProvider<ButtonRotatedNotifier, bool>(ButtonRotatedNotifier.new);

class ButtonRotatedNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() {
    state = !state;
  }
}

final fragmentIndexProvider = NotifierProvider<FragmentIndexNotifier, int>(FragmentIndexNotifier.new);

class FragmentIndexNotifier extends Notifier<int> {
  @override
  int build() {
    return FragmentIndex.files;
  }

  void setIndex(int index) {
    state = index;
  }
}

final historyProvider =
NotifierProvider<HistoryNotifier, List<FileModel>>(HistoryNotifier.new);

class HistoryNotifier extends Notifier<List<FileModel>> {
  @override
  List<FileModel> build() => [FileModel(id: "")];

  FileModel currentFolder() {
    return state.lastOrNull ?? FileModel(id: "");
  }

  void insertHistory(FileModel fileModel) {
    state = [...state, fileModel];
  }

  void pop() {
    if (state.length > 1) {
      state = state.sublist(0, state.length - 1);
    }
  }

  void clear() {
    state = [FileModel(id: "")];
  }

  void popIndex(int index) {
    state = state.sublist(0, index + 1);
  }
}

final searchKeywordProvider = NotifierProvider<SearchKeywordNotifier, String?>(SearchKeywordNotifier.new);

class SearchKeywordNotifier extends Notifier<String?> {
  @override
  String? build() {
    return null;
  }

  void setKeyword(String keyword) {
    state = keyword;
  }

  void startSearch() {
    state = "";
  }

  void endSearch() {
    state = null;
  }
}

class SelectedFilesNotifier extends Notifier<List<String>?> {
  
  @override
  List<String>? build() {
    return null;
  }
  
  void addId(String id) {
    if(state == null) {
      return;
    }
    if (!state!.contains(id)) {
      state = [...state!, id];
    }
  }

  void removeId(String id) {
    if(state == null) {
      return;
    }
    state = state!.where((e) => e != id).toList();
  }

  void startSelection() {
    state = [];
  }

  void endSelection() {
    state = null;
  }

}

final selectedFilesProvider = NotifierProvider<SelectedFilesNotifier, List<String>?>(SelectedFilesNotifier.new);

final showingFileProvider = NotifierProvider<ShowingFileNotifier, FileModel?>(ShowingFileNotifier.new);

class ShowingFileNotifier extends Notifier<FileModel?> {

  @override
  FileModel? build() {
    return null;
  }

  void toggleVisibility(FileModel fileModel) {
    if(state?.id == fileModel.id) {
      state = null;
    }
    else {
      state = fileModel;
    }
  }
}