import 'package:hive/hive.dart';

import 'package:comiksan/model/chapter.dart';
import 'package:comiksan/model/import.dart';

part 'comic.g.dart'; // This will be generated

@HiveType(typeId: 0) // Use typeId 0 for Comic
class Comic {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String author;

  @HiveField(3)
  final String genre;

  @HiveField(4)
  final DateTime lastSynced;

  @HiveField(5)
  final int followerCount;

  @HiveField(6)
  final String? mangaDexId;

  @HiveField(7)
  final String? description;

  @HiveField(8)
  final String? coverImageUrl;

  @HiveField(9)
  final List<Chapter> chapters;

  Comic({
    required this.id,
    required this.title,
    required this.author,
    required this.genre,
    required this.lastSynced,
    required this.followerCount,
    this.mangaDexId,
    this.description,
    this.coverImageUrl,
    required this.chapters,
  });

  // ✅ ADD COPYWITH METHOD FOR DOWNLOAD SERVICE
  Comic copyWith({
    int? id,
    String? title,
    String? author,
    String? genre,
    DateTime? lastSynced,
    int? followerCount,
    String? mangaDexId,
    String? description,
    String? coverImageUrl,
    List<Chapter>? chapters,
  }) {
    return Comic(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      genre: genre ?? this.genre,
      lastSynced: lastSynced ?? this.lastSynced,
      followerCount: followerCount ?? this.followerCount,
      mangaDexId: mangaDexId ?? this.mangaDexId,
      description: description ?? this.description,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      chapters: chapters ?? this.chapters,
    );
  }

  factory Comic.fromJson(Map<String, dynamic> json) {
    return Comic(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Unknown Title',
      author: json['author'] ?? 'Unknown Author',
      genre: json['genre'] ?? 'Manga',
      lastSynced: DateTime.parse(json['lastSynced']),
      followerCount: json['followerCount'] ?? 0,
      mangaDexId: json['mangaDexId'],
      description: json['description'],
      coverImageUrl: json['coverImageUrl'],
      chapters:
          (json['chapters'] as List<dynamic>?)
              ?.map((chapter) => Chapter.fromJson(chapter))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'author': author,
    'genre': genre,
    'followerCount': followerCount,
    'mangaDexId': mangaDexId,
    'description': description,
    'coverImageUrl': coverImageUrl,
    'lastSynced': lastSynced.toIso8601String(),
    'chapters': chapters.map((chapter) => chapter.toJson()).toList(),
  };
}
