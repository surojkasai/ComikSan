//code for when we browse individual comicks

import 'package:cached_network_image/cached_network_image.dart';
import 'package:comiksan/model/comic.dart';
import 'package:comiksan/providers/comic_providers.dart';
import 'package:comiksan/section/ChapterlistSection.dart';
import 'package:comiksan/util/headfooter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ComickDetails extends StatefulWidget {
  final Comic comic;
  const ComickDetails({super.key, required this.comic});

  @override
  State<ComickDetails> createState() => _ComickDetailsState();
}

class _ComickDetailsState extends State<ComickDetails> {
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
    // print('Existing chapters in comic: ${widget.comic.chapters.length}');
    // final testMangaDexId = 'a1c7c817-4e59-43b7-9365-09675a149a6f'; // One Piece

    // print('🔄 TEST: Using MangaDex ID: $testMangaDexId');
    // Store in local variable for null safety
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
                                    onPressed: () {
                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //     builder: (context) => ComicReader(chapter: chapter),
                                      //   ),
                                      // );
                                    },
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      minimumSize: Size(100, 50),
                                    ),
                                    child: Text(
                                      'Continue',
                                      style: TextStyle(fontSize: 15, color: Colors.white),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Flexible(
                                  child: TextButton(
                                    onPressed: () {},
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      minimumSize: Size(100, 50),
                                    ),

                                    child: Text(
                                      'Reading',
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
    return ChaptersSection(chapters: _chapters, mangaDexId: widget.comic.mangaDexId!);
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
