import 'package:amphi/utils/file_name_utils.dart';
import 'package:cloud/models/app_settings.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class FileModel {

  String id;
  Map<String, dynamic> data;

  FileModel({required this.id, Map<String, dynamic>? data}) : data = data ?? {};

  String get name => data["name"] ?? "";
  set name(String value) => data["name"] = value;

  String get parentId => data["parent_id"] ?? "";
  set parentId(String value) => data["parent_id"] = value;

  bool get isFolder => data["type"] == "folder";
  set isFolder(bool value) => data["type"] = value ? "folder" : "file";

  String get sha256 => data["sha256"] ?? "";
  set sha256(String value) => data["sha256"] = value;

  int get size => data["size"] ?? 0;
  set size(int value) => data["size"] = value;

  DateTime get created => DateTime.fromMillisecondsSinceEpoch(data["created"] ?? 0).toLocal();
  set created(DateTime dateTime) {
    data["created"] = dateTime.toUtc().millisecondsSinceEpoch;
  }

  DateTime get modified => DateTime.fromMillisecondsSinceEpoch(data["modified"] ?? 0).toLocal();
  set modified(DateTime dateTime) {
    data["modified"] = dateTime.toUtc().millisecondsSinceEpoch;
  }

  DateTime get uploaded => DateTime.fromMillisecondsSinceEpoch(data["uploaded"] ?? 0).toLocal();
  set uploaded(DateTime dateTime) {
    data["uploaded"] = dateTime.toUtc().millisecondsSinceEpoch;
  }

  DateTime? get deleted {
    var value = data["deleted"];
    if(value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value).toLocal();
    }
    return null;
  }

  set deleted(DateTime? dateTime) {
    if(dateTime == null) {
      data.remove("deleted");
    }
    else {
      data["deleted"] = dateTime.toUtc().millisecondsSinceEpoch;
    }
  }

  String get fileExtension => FilenameUtils.extensionName(name);

  bool isImage() {
    const imageExtensions = { "webp", "jpg", "jpeg", "png", "gif", "bmp", "tiff", "tif", "svg",
      "ico", "heic", "heif", "jfif", "pjpeg", "pjp", "avif",
      "raw", "dng", "cr2", "nef", "arw", "rw2", "orf", "sr2", "raf", "pef",
      "mp4", "mov", "avi", "wmv", "mkv", "flv", "webm", "mpeg", "mpg", "m4v", "3gp", "3g2", "f4v", "swf", "vob", "ts"};
    return imageExtensions.contains(fileExtension);
  }

  bool isVideo() {
    const videoExtensions = { "mp4", "mov", "avi", "wmv", "mkv", "flv", "webm", "mpeg", "mpg", "m4v", "3gp", "3g2", "f4v", "swf", "vob", "ts"};
    return videoExtensions.contains(fileExtension);
  }

  String sortOptionId() {
    if(id.isEmpty) {
      return "!FILES";
    }
    else {
      return id;
    }
  }

}

extension DateTimeEx on DateTime {
  String toLocalizedString(BuildContext context) {
    return "${DateFormat.yMMMEd(Localizations.localeOf(context).languageCode.toString()).format(this)}   ${DateFormat.jm(appSettings.locale?.languageCode ?? "en").format(this)}";
  }
}