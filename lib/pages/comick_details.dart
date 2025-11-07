//code for when we browse individual comicks

import 'package:cached_network_image/cached_network_image.dart';
import 'package:comiksan/model/bookmark_model.dart';
import 'package:comiksan/model/chapter.dart';
import 'package:comiksan/model/comic.dart';
import 'package:comiksan/model/import.dart';
import 'package:comiksan/model/import.dart' as comic_model;
import 'package:comiksan/pages/ComicReader.dart';
import 'package:comiksan/providers/comic_providers.dart';
import 'package:comiksan/section/ChapterlistSection.dart';
import 'package:comiksan/services/api_service.dart';
import 'package:comiksan/util/headfooter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

class ComickDetails extends StatefulWidget {
  final Comic comic;
  const ComickDetails({super.key, required this.comic});

  @override
  State<ComickDetails> createState() => _ComickDetailsState();
}

class _ComickDetailsState extends State<ComickDetails> {
  final ApiService _apiService = ApiService();
  bool _isImporting = false;
  // ✅ ADD THIS METHOD - Handle import functionality
  Future<void> _importComic() async {
    if (_isImporting) return; // Prevent multiple clicks

    setState(() {
      _isImporting = true;
    });

    try {
      print('🔄 Starting import for: ${widget.comic.title}');

      // Show loading snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(width: 16),
              Text('Adding "${widget.comic.title}" to library...'),
            ],
          ),
          duration: Duration(seconds: 5),
        ),
      );

      // Call the import API
      final result = await _apiService.importMangaByTitle(widget.comic.title);

      // Hide loading snackbar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      print('✅ Import successful: ${result.message}');
    } catch (e) {
      // Hide loading snackbar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add to library: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );

      print('❌ Import failed: $e');
    } finally {
      setState(() {
        _isImporting = false;
      });
    }
  }

  // Generate details from the Comic object
  List<Map<String, String>> get details {
    return [
      {'label': 'Origination:', 'value': 'Manga'}, // You can add this to your Comic model later
      {'label': 'Author:', 'value': widget.comic.author},
      {'label': 'Genre:', 'value': widget.comic.genre},
      {'label': 'Status:', 'value': 'Ongoing'}, // You can add this to your Comic model
      {'label': 'Rating:', 'value': '9.5'}, // You can add this to your Comic model
    ];
  }

  final user = FirebaseAuth.instance.currentUser;
  String get testUrl {
    // Test with Warui ga Watashi wa Yuri ja nai cover (this is a real working URL)
    return 'https://uploads.mangadex.org/covers/8f3e1818-a015-491d-bd81-3addc4d7d56a/26dd2770-d383-42e9-a42b-32765a4d99c8.png';
  }

  List<Chapter> _chapters = [];
  bool _loadingChapters = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadChapters();
  }

  Future<void> _loadChapters() async {
    // ✅ CHECK IF WE ALREADY HAVE CHAPTERS IN THE COMIC
    print('=== FLUTTER: ComickDetails loading chapters ===');
    print('Comic title: ${widget.comic.title}');
    print('MangaDex ID: ${widget.comic.mangaDexId}');

    final mangaDexId = widget.comic.mangaDexId;
    // If comic already has chapters, use them
    if (widget.comic.chapters.isNotEmpty) {
      print('✅ Using existing chapters from comic object');
      setState(() {
        _chapters = widget.comic.chapters;
      });
      return;
    }

    // If no MangaDex ID, we can't load chapters
    if (widget.comic.mangaDexId == null) {
      print('❌ No MangaDex ID available for this comic');
      setState(() {
        _error = 'No MangaDex ID available';
      });
      return;
    }

    setState(() {
      _loadingChapters = true;
      _error = '';
    });

    try {
      print('🔄 Loading chapters from API...');
      final comicProvider = Provider.of<ComicProvider>(context, listen: false);
      final chapters = await comicProvider.loadChapters(mangaDexId!);
      setState(() {
        _chapters = chapters;
        _loadingChapters = false;
      });

      print('✅ Chapters loaded successfully: ${_chapters.length}');
    } catch (e) {
      print('❌ Error loading chapters: $e');
      setState(() {
        _loadingChapters = false;
        _error = 'Failed to load chapters: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Headfooter(
      body: Scaffold(
        body: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height - kToolbarHeight - kBottomNavigationBarHeight,
            ),
            child: Container(
              padding: EdgeInsets.all(10),
              color: Colors.black,
              child: Column(
                children: [
                  Text(widget.comic.title, style: TextStyle(fontSize: 25, color: Colors.white)),
                  Container(
                    //color: Colors.blueGrey,
                    height: 300,
                    width: double.infinity,
                    child: Row(
                      children: [
                        Container(
                          //color: Colors.red,
                          height: 250,
                          width: 150,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child:
                                widget.comic.coverImageUrl != null &&
                                        widget.comic.coverImageUrl!.isNotEmpty
                                    ? CachedNetworkImage(
                                      // imageUrl:
                                      //     widget.comic.id == 9
                                      //         ? testUrl
                                      //         : widget.comic.coverImageUrl!, // Test with comic ID 9
                                      imageUrl: widget.comic.coverImageUrl!,
                                      fit: BoxFit.cover,

                                      width: 110,
                                      height: 150,
                                      placeholder:
                                          (context, url) => Container(
                                            color: Colors.grey[800],
                                            child: Center(child: CircularProgressIndicator()),
                                          ),
                                      errorWidget:
                                          (context, url, error) => _buildPlaceholderImage(),
                                    )
                                    : _buildPlaceholderImage(),
                          ),
                        ),

                        Expanded(
                          child: Container(
                            padding: EdgeInsets.only(top: 20, right: 10, left: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...details
                                    .map(
                                      (item) => Row(
                                        children: [
                                          Text(
                                            item['label']!,
                                            style: TextStyle(fontSize: 15, color: Colors.white),
                                          ),
                                          SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              item['value']!,
                                              style: TextStyle(fontSize: 15, color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                    .toList(),

                                const SizedBox(height: 10),
                                Flexible(
                                  child: TextButton(
                                    onPressed: () async {
                                      final currentComic = widget.comic;
                                      if (currentComic == null) return;

                                      final box = Hive.box<BookmarkModel>('bookmarks');
                                      final saved = box.get(currentComic.id.toString());

                                      final api = ApiService();

                                      // show small loading dialog while we fetch chapter(s)
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder:
                                            (_) => Dialog(
                                              backgroundColor: Colors.transparent,
                                              child: Container(
                                                padding: const EdgeInsets.all(20),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[900],
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: const Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    CircularProgressIndicator(),
                                                    SizedBox(height: 12),
                                                    Text(
                                                      'Loading...',
                                                      style: TextStyle(color: Colors.white),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                      );

                                      try {
                                        if (saved != null) {
                                          // Bookmark exists
                                          final chapterId = saved.chapterId;
                                          final startPage = saved.pageNumber;

                                          final chapterWithPages = await api.getChapterPages(
                                            chapterId,
                                          );
                                          Navigator.of(context).pop();
                                          if (!mounted) return;

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) => ComicReader(
                                                    comic: currentComic,
                                                    chapter: chapterWithPages,
                                                    fetchChapter: (id) => api.getChapterPages(id),
                                                    fetchChapterList:
                                                        () => api.getChapters(
                                                          currentComic.mangaDexId ?? '',
                                                        ),
                                                    startPage:
                                                        startPage, // pass the bookmarked page
                                                  ),
                                            ),
                                          );
                                        } else {
                                          // No bookmark, start from first chapter
                                          final chapters = await api.getChapters(
                                            currentComic.mangaDexId ?? '',
                                          );
                                          if (chapters.isEmpty) {
                                            Navigator.of(context).pop();
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('No chapters available'),
                                              ),
                                            );
                                            return;
                                          }

                                          final first = chapters.first;
                                          final chapterWithPages = await api.getChapterPages(
                                            first.chapterId,
                                          );
                                          Navigator.of(context).pop(); // close loading dialog
                                          if (!mounted) return;

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) => ComicReader(
                                                    comic: currentComic,
                                                    chapter: chapterWithPages,
                                                    fetchChapter: (id) => api.getChapterPages(id),
                                                    fetchChapterList:
                                                        () => api.getChapters(
                                                          currentComic.mangaDexId ?? '',
                                                        ),
                                                    startPage: 0,
                                                  ),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        Navigator.of(context).pop();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Failed to open reader: $e')),
                                        );
                                      }
                                    },
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      minimumSize: const Size(100, 50),
                                    ),
                                    child: const Text(
                                      'Continue',
                                      style: TextStyle(fontSize: 15, color: Colors.white),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),

                                Flexible(
                                  child: TextButton(
                                    onPressed:
                                        _isImporting ? null : _importComic, // Disable when loading
                                    style: TextButton.styleFrom(
                                      backgroundColor:
                                          _isImporting
                                              ? Colors.grey
                                              : Colors.blue, // Change color when loading
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      minimumSize: Size(100, 50),
                                    ),
                                    child:
                                        _isImporting
                                            ? Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor: AlwaysStoppedAnimation<Color>(
                                                      Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  'Adding...',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            )
                                            : Text(
                                              'Add to Library', // Consider updating text to reflect the action
                                              style: TextStyle(fontSize: 15, color: Colors.white),
                                            ),
                                  ),
                                ),
                                //IconButton(onPressed: () {}, icon: Icon(Icons.download_for_offline)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text('Description', style: TextStyle(color: Colors.white, fontSize: 20)),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(widget.comic.coverImageUrl ?? ''),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Overlay that takes full size of parent
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        // Scrollable text inside
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: SingleChildScrollView(
                            child: Text(
                              widget.comic.description ?? 'No description',
                              textAlign: TextAlign.justify,
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildChaptersSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChaptersSection() {
    if (_loadingChapters) {
      return Container(
        margin: EdgeInsets.only(top: 20),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text('Loading chapters...', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Container(
        margin: EdgeInsets.only(top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Error loading chapters:', style: TextStyle(color: Colors.red)),
            Text(_error, style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    }
    if (_chapters.isEmpty) {
      return Container(
        margin: EdgeInsets.only(top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('No chapters available yet', style: TextStyle(color: Colors.white, fontSize: 16)),
            SizedBox(height: 10),
            Text('Debug info:', style: TextStyle(color: Colors.grey)),
            Text(
              'MangaDex ID: ${widget.comic.mangaDexId ?? "null"}',
              style: TextStyle(color: Colors.grey),
            ),
            Text('Chapters list length: ${_chapters.length}', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    return ChaptersSection(
      comic: widget.comic,
      chapters: _chapters,
      mangaDexId: widget.comic.mangaDexId!,
    );
  }
}

Widget _buildPlaceholderImage() {
  return Container(
    height: 150,
    width: 110,
    color: Colors.grey[800],
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.image, color: Colors.white54, size: 40),
        SizedBox(height: 8),
        Text('No Cover', style: TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    ),
  );
}
