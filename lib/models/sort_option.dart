abstract final class SortOption {
  static const created = "created";
  static const createdDescending = "created,descending";
  static const modified = "modified";
  static const modifiedDescending = "modified,descending";
  static const uploaded = "uploaded";
  static const uploadedDescending = "uploaded,descending";
  static const deleted = "deleted";
  static const deletedDescending = "deleted,descending";
  static const name = "name";
  static const nameDescending = "name,descending";
  static const size = "size";
  static const sizeDescending = "size,descending";
}

extension DescendingEx on String {
  bool isDescending() => endsWith(",descending");
}