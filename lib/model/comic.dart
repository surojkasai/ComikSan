class Comic {
  final int id;
  final String title;
  final String author;
  final String genre;
  final int followerCount;
  final String? mangaDexId;
  final String? description;
  final String? coverImageUrl;
  final List<Chapter> chapters;

  Comic({
    required this.id,
    required this.title,
    required this.author,
    required this.genre,
    required this.followerCount,
    this.mangaDexId,
    this.description,
    this.coverImageUrl,
    required this.chapters,
  });

  factory Comic.fromJson(Map<String, dynamic> json) {
    return Comic(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Unknown Title',
      author: json['author'] ?? 'Unknown Author',
      genre: json['genre'] ?? 'Manga',
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
    // 'lastSynced': lastSynced?.toIso8601String(),
    'chapters': chapters.map((chapter) => chapter.toJson()).toList(),
  };
}

// New Chapter model
class Chapter {
  final String chapterId;
  final String title;
  final String chapterNumber;
  final List<Page> pages;
  final String? groupName;
  final DateTime? publishedAt;

  Chapter({
    required this.chapterId,
    required this.title,
    required this.chapterNumber,
    required this.pages,
    this.publishedAt,
    this.groupName = 'Unknown Group',
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      chapterId: json['chapterId'] ?? json['id'] ?? '',
      title: json['title'] ?? 'Chapter',
      chapterNumber: json['chapterNumber'] ?? '0',
      pages: (json['pages'] as List<dynamic>?)?.map((page) => Page.fromJson(page)).toList() ?? [],
      publishedAt: json['publishedAt'] != null ? DateTime.parse(json['publishedAt']) : null,
      groupName: json['groupName'] ?? 'Unknown Group',
    );
  }

  Map<String, dynamic> toJson() => {
    'chapterId': chapterId,
    'title': title,
    'chapterNumber': chapterNumber,
    'pages': pages.map((page) => page.toJson()).toList(),
    'publishedAt': publishedAt?.toIso8601String(),
    'groupName': groupName,
  };
}

// New Page model
class Page {
  final int pageNumber;
  final String imageUrl;
  final int width;
  final int height;

  Page({
    required this.pageNumber,
    required this.imageUrl,
    required this.width,
    required this.height,
  });

  factory Page.fromJson(Map<String, dynamic> json) {
    return Page(
      pageNumber: json['pageNumber'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
      width: json['width'] ?? 0,
      height: json['height'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'pageNumber': pageNumber,
    'imageUrl': imageUrl,
    'width': width,
    'height': height,
  };
}

// Add this model class (create a new file models/import_result.dart or add to existing models)
class ImportResult {
  final String message;
  final List<Comic>? comics;
  final List<String>? searchedTitles;

  ImportResult({required this.message, this.comics, this.searchedTitles});

  factory ImportResult.fromJson(Map<String, dynamic> json) {
    return ImportResult(
      message: json['message'],
      comics:
          json['comics'] != null
              ? (json['comics'] as List).map((i) => Comic.fromJson(i)).toList()
              : null,
      searchedTitles:
          json['searchedTitles'] != null ? List<String>.from(json['searchedTitles']) : null,
    );
  }
}
