import 'package:hive/hive.dart';

part 'page.g.dart'; // This will be generated

@HiveType(typeId: 2) // Use typeId 2 for Page
class Page {
  @HiveField(0)
  final int pageNumber;

  @HiveField(1)
  final String imageUrl;

  @HiveField(2)
  final int width;

  @HiveField(3)
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

  // ✅ COPYWITH METHOD FOR DOWNLOAD SERVICE
  Page copyWith({int? pageNumber, String? imageUrl, int? width, int? height}) {
    return Page(
      pageNumber: pageNumber ?? this.pageNumber,
      imageUrl: imageUrl ?? this.imageUrl,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }
}
