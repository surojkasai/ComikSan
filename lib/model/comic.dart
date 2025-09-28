class Comic {
  final int id;
  final String title;
  final String author;
  final String genre;
  final int followerCount;
  final String? mangaDexId;
  final String? description;
  final String? coverImageUrl;
  final DateTime? lastSynced;
  final List<dynamic> chapters;

  Comic({
    required this.id,
    required this.title,
    required this.author,
    required this.genre,
    required this.followerCount,
    this.mangaDexId,
    this.description,
    this.coverImageUrl,
    this.lastSynced,
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
      lastSynced: json['lastSynced'] != null ? DateTime.parse(json['lastSynced']) : null,
      chapters: json['chapters'] ?? [],
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
    'lastSynced': lastSynced?.toIso8601String(),
    'chapters': chapters,
  };
}
