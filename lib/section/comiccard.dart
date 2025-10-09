import 'package:comiksan/model/comic.dart';
import 'package:comiksan/pages/comick_details.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ComicCard extends StatelessWidget {
  final Comic comic;
  final IconData downloadIcon;
  final String? chapterno;
  final String? publishedAt;
  final String? translator;
  final VoidCallback? onDownloadTap;

  const ComicCard({
    super.key,
    required this.comic,
    required this.downloadIcon,
    this.chapterno,
    this.publishedAt,
    this.translator,
    this.onDownloadTap, // Optional callback for download
  });

  // Get the latest chapter info
  String get _latestChapterNumber {
    if (comic.chapters.isNotEmpty) {
      final latestChapter = comic.chapters.last;
      return 'Ch. ${latestChapter.chapterNumber}';
    }
    return chapterno ?? 'No chapters';
  }

  String get _latestChapterTime {
    if (comic.chapters.isNotEmpty) {
      final latestChapter = comic.chapters.last;
      if (latestChapter.publishedAt != null) {
        return _formatTimeAgo(latestChapter.publishedAt!);
      }
    }
    return publishedAt ?? '';
  }

  String get _latestTranslator {
    if (comic.chapters.isNotEmpty) {
      final latestChapter = comic.chapters.last;
      return latestChapter.groupName ?? translator ?? '';
    }
    return translator ?? '';
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ComickDetails(comic: comic)),
        );
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Container with Stack for download icon
            Container(
              width: 120,
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child:
                        comic.coverImageUrl != null
                            ? Image.network(
                              comic.coverImageUrl!,
                              fit: BoxFit.cover,
                              width: 120,
                              height: 180,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[800],
                                  child: const Icon(Icons.broken_image, color: Colors.white),
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: Colors.grey[800],
                                  child: const Center(
                                    child: CircularProgressIndicator(color: Colors.amber),
                                  ),
                                );
                              },
                            )
                            : Container(
                              color: Colors.grey[800],
                              child: const Icon(Icons.book, color: Colors.white),
                            ),
                  ),

                  // Download IconButton in top-right corner
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton(
                      onPressed: onDownloadTap,
                      icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(downloadIcon, color: Colors.white, size: 16),
                      ),
                      splashRadius: 16, // Controls the splash effect size
                      padding: EdgeInsets.zero, // Remove default padding
                      constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Text Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _latestChapterNumber,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // Upload Time
                if (_latestChapterTime.isNotEmpty)
                  Text(
                    _latestChapterTime,
                    style: const TextStyle(color: Colors.grey, fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                // Translator Group
                if (_latestTranslator.isNotEmpty)
                  Text(
                    _latestTranslator,
                    style: const TextStyle(color: Colors.white70, fontSize: 9),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                //comic title
                Text(
                  comic.title,
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  comic.author,
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  comic.title,
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
