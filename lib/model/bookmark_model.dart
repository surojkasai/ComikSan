import 'package:hive/hive.dart';

part 'bookmark_model.g.dart'; // This will be generated later

@HiveType(typeId: 3)
class BookmarkModel {
  @HiveField(0)
  final String comicId;

  @HiveField(1)
  final String chapterId;

  @HiveField(2)
  final int pageNumber;

  BookmarkModel({required this.comicId, required this.chapterId, required this.pageNumber});
}
