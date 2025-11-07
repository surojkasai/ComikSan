import 'package:comiksan/model/import.dart';
import 'package:comiksan/model/page.dart';
import 'package:hive/hive.dart';

part 'chapter.g.dart'; // This will be generated

@HiveType(typeId: 1) // Use typeId 1 for Chapter
class Chapter {
  @HiveField(0)
  final String chapterId;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String chapterNumber;

  @HiveField(3)
  final List<Page> pages;

  @HiveField(4)
  final String? groupName;

  @HiveField(5)
  final DateTime? publishedAt;

  @HiveField(6)
  final bool isDownloaded;

  @HiveField(7)
  final String? localPath;

  Chapter({
    required this.chapterId,
    required this.title,
    required this.chapterNumber,
    required this.pages,
    this.publishedAt,
    this.groupName = 'Unknown Group',
    this.isDownloaded = false,
    this.localPath,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      chapterId: json['chapterId'] ?? json['id'] ?? '',
      title: json['title'] ?? 'Chapter',
      chapterNumber: json['chapterNumber'] ?? '0',
      pages: (json['pages'] as List<dynamic>?)?.map((page) => Page.fromJson(page)).toList() ?? [],
      publishedAt: json['publishedAt'] != null ? DateTime.parse(json['publishedAt']) : null,
      groupName: json['groupName'] ?? 'Unknown Group',
      isDownloaded: json['isDownloaded'] ?? false, // ✅ FIXED: Remove .hashCode
      localPath: json['localPath'],
    );
  }

  Map<String, dynamic> toJson() => {
    'chapterId': chapterId,
    'title': title,
    'chapterNumber': chapterNumber,
    'pages': pages.map((page) => page.toJson()).toList(),
    'publishedAt': publishedAt?.toIso8601String(),
    'groupName': groupName,
    'isDownloaded': isDownloaded,
    'localPath': localPath,
  };

  // ✅ COPYWITH METHOD FOR DOWNLOAD SERVICE
  Chapter copyWith({
    String? chapterId,
    String? title,
    String? chapterNumber,
    List<Page>? pages,
    String? groupName,
    DateTime? publishedAt,
    bool? isDownloaded,
    String? localPath,
  }) {
    return Chapter(
      chapterId: chapterId ?? this.chapterId,
      title: title ?? this.title,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      pages: pages ?? this.pages,
      groupName: groupName ?? this.groupName,
      publishedAt: publishedAt ?? this.publishedAt,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      localPath: localPath ?? this.localPath,
    );
  }
}
