// Add this model class (create a new file models/import_result.dart or add to existing models)
import 'package:comiksan/model/comic.dart';

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
