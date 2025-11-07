import 'package:comiksan/model/comic.dart';
import 'package:comiksan/pages/comick_details.dart';
import 'package:comiksan/section/footersection.dart';
import 'package:comiksan/services/search_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Headfooter extends StatefulWidget {
  final Widget body;
  final Widget? LastReadIcon;
  final Widget? searchIcon;

  const Headfooter({super.key, this.searchIcon, this.LastReadIcon, required this.body});

  @override
  State<Headfooter> createState() => _HeadfooterState();
}

class _HeadfooterState extends State<Headfooter> {
  final user = FirebaseAuth.instance.currentUser;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  void _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
    });
    try {
      print('🔍 Starting search for: $query');
      final List<Comic> results = await SearchService.searchManga(query);
      print('✅ Search completed, found ${results.length} results');

      // Close the dialog
      Navigator.of(context).pop();

      // Show search results in a new screen or dialog
      _showSearchResults(results, query);
    } catch (e) {
      // Show error
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Search failed: $e'), backgroundColor: Colors.red));
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _showSearchResults(List<Comic> results, String query) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            'Search Results for "$query"',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          content: Container(
            width: double.maxFinite,
            child:
                results.isEmpty
                    ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off, color: Colors.white54, size: 50),
                        SizedBox(height: 16),
                        Text('No manga found', style: TextStyle(color: Colors.white70)),
                      ],
                    )
                    : ListView.builder(
                      shrinkWrap: true,
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final comic = results[index];
                        return _buildSearchResultItem(comic, context);
                      },
                    ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close', style: TextStyle(color: Colors.white70)),
            ),
          ],
        );
      },
    );
  }

  // Widget _buildSearchResultItem(Comic comic, BuildContext context) {
  //   return Card(
  //     color: Colors.grey[800],
  //     margin: EdgeInsets.symmetric(vertical: 4),
  //     child: ListTile(
  //       leading:
  //           comic.coverImageUrl != null
  //               ? ClipRRect(
  //                 borderRadius: BorderRadius.circular(8),
  //                 child: Image.network(
  //                   comic.coverImageUrl!,
  //                   fit: BoxFit.cover,
  //                   width: 50,
  //                   height: 70,
  //                   errorBuilder: (context, error, stackTrace) {
  //                     return Container(
  //                       width: 50,
  //                       height: 70,
  //                       color: Colors.grey[700],
  //                       child: Icon(Icons.broken_image, color: Colors.white54),
  //                     );
  //                   },
  //                   loadingBuilder: (context, child, loadingProgress) {
  //                     if (loadingProgress == null) return child;
  //                     return Container(
  //                       color: Colors.grey[800],
  //                       child: const Center(child: CircularProgressIndicator(color: Colors.amber)),
  //                     );
  //                   },
  //                 ),
  //               )
  //               : Container(
  //                 width: 50,
  //                 height: 70,
  //                 color: Colors.grey[700],
  //                 child: Icon(Icons.image, color: Colors.white54),
  //               ),
  //       title: Text(
  //         comic.title,
  //         style: TextStyle(color: Colors.white, fontSize: 14),
  //         maxLines: 2,
  //         overflow: TextOverflow.ellipsis,
  //       ),
  //       subtitle: Text(
  //         comic.genre ?? 'Manga',
  //         style: TextStyle(color: Colors.white70, fontSize: 12),
  //       ),
  //       trailing: Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
  //       onTap: () {
  //         // Navigate to comic details page
  //         _navigateToComicDetails(comic, context);
  //       },
  //     ),
  //   );
  // }

  Widget _buildSearchResultItem(Comic comic, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.amber.withOpacity(0.2),
        onTap: () => _navigateToComicDetails(comic, context),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 6, offset: Offset(0, 3)),
            ],
          ),
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              // Cover Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child:
                    comic.coverImageUrl != null
                        ? Image.network(
                          comic.coverImageUrl!,
                          fit: BoxFit.cover,
                          width: 50,
                          height: 70,
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                width: 50,
                                height: 70,
                                color: Colors.grey[700],
                                child: Icon(Icons.broken_image, color: Colors.white54),
                              ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 50,
                              height: 70,
                              color: Colors.grey[800],
                              child: Center(
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                        : Container(
                          width: 50,
                          height: 70,
                          color: Colors.grey[700],
                          child: Icon(Icons.image, color: Colors.white54),
                        ),
              ),
              SizedBox(width: 12),
              // Title & Genre
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comic.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      comic.genre ?? 'Manga',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToComicDetails(Comic comic, BuildContext context) {
    // Close the search results dialog first
    Navigator.of(context).pop();

    // Navigate to comic details page
    // You'll need to create this page or use your existing one
    Navigator.push(context, MaterialPageRoute(builder: (context) => ComickDetails(comic: comic)));
  }

  // void _showSearchDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return StatefulBuilder(
  //         builder: (context, setState) {
  //           return AlertDialog(
  //             backgroundColor: Colors.grey[900],
  //             title: Text('Search Manga', style: TextStyle(color: Colors.amber, fontSize: 20)),
  //             content: Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 TextField(
  //                   controller: _searchController,
  //                   decoration: InputDecoration(
  //                     hintText: 'Search for manga...',
  //                     hintStyle: TextStyle(color: Colors.white54),
  //                     enabledBorder: UnderlineInputBorder(
  //                       borderSide: BorderSide(color: Colors.white38),
  //                     ),
  //                     focusedBorder: UnderlineInputBorder(
  //                       borderSide: BorderSide(color: Colors.blue),
  //                     ),
  //                   ),
  //                   style: TextStyle(color: Colors.white),
  //                   onSubmitted: (_) => _performSearch(),
  //                 ),
  //                 SizedBox(height: 16),
  //                 if (_isSearching)
  //                   Column(
  //                     children: [
  //                       CircularProgressIndicator(),
  //                       SizedBox(height: 8),
  //                       Text('Searching...', style: TextStyle(color: Colors.white70)),
  //                     ],
  //                   ),
  //               ],
  //             ),
  //             actions: [
  //               TextButton(
  //                 onPressed: () {
  //                   Navigator.pop(context);
  //                 },
  //                 child: Text('Close', style: TextStyle(color: Colors.white70)),
  //               ),
  //               ElevatedButton(
  //                 onPressed: _isSearching ? null : _performSearch,
  //                 style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
  //                 child:
  //                     _isSearching
  //                         ? SizedBox(
  //                           width: 16,
  //                           height: 16,
  //                           child: CircularProgressIndicator(
  //                             strokeWidth: 2,
  //                             valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
  //                           ),
  //                         )
  //                         : Text('Search', style: TextStyle(color: Colors.white)),
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //     },
  //   );
  // }
  // void _showSearchDialog() {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: true, // tap outside to close
  //     builder: (BuildContext context) {
  //       return StatefulBuilder(
  //         builder: (context, setState) {
  //           return Dialog(
  //             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  //             backgroundColor: Colors.grey[900],
  //             insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
  //             child: Padding(
  //               padding: const EdgeInsets.all(20),
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   Text(
  //                     'Search Manga',
  //                     style: TextStyle(
  //                       color: Colors.amber,
  //                       fontSize: 22,
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                   SizedBox(height: 16),
  //                   TextField(
  //                     controller: _searchController,
  //                     decoration: InputDecoration(
  //                       hintText: 'Search for manga...',
  //                       hintStyle: TextStyle(color: Colors.white54),
  //                       filled: true,
  //                       fillColor: Colors.grey[850],
  //                       border: OutlineInputBorder(
  //                         borderRadius: BorderRadius.circular(12),
  //                         borderSide: BorderSide.none,
  //                       ),
  //                       contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //                     ),
  //                     style: TextStyle(color: Colors.white),
  //                     onSubmitted: (_) => _performSearch(),
  //                   ),
  //                   SizedBox(height: 20),
  //                   if (_isSearching)
  //                     Row(
  //                       mainAxisAlignment: MainAxisAlignment.center,
  //                       children: [
  //                         SizedBox(
  //                           width: 24,
  //                           height: 24,
  //                           child: LinearProgressIndicator(
  //                             backgroundColor: Colors.grey[800],
  //                             valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
  //                           ),
  //                         ),
  //                         SizedBox(width: 12),
  //                         Text('Searching...', style: TextStyle(color: Colors.white70)),
  //                       ],
  //                     ),
  //                   if (!_isSearching)
  //                     Row(
  //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                       children: [
  //                         Expanded(
  //                           child: InkWell(
  //                             onTap: () => Navigator.pop(context),
  //                             borderRadius: BorderRadius.circular(12),
  //                             splashColor: Colors.amber.withOpacity(0.2),
  //                             child: Container(
  //                               padding: EdgeInsets.symmetric(vertical: 12),
  //                               decoration: BoxDecoration(
  //                                 borderRadius: BorderRadius.circular(12),
  //                                 border: Border.all(color: Colors.white38),
  //                                 color: Colors.grey[850],
  //                               ),
  //                               alignment: Alignment.center,
  //                               child: Text('Close', style: TextStyle(color: Colors.white70)),
  //                             ),
  //                           ),
  //                         ),
  //                         SizedBox(width: 16),
  //                         Expanded(
  //                           child: InkWell(
  //                             onTap: _isSearching ? null : _performSearch,
  //                             borderRadius: BorderRadius.circular(12),
  //                             splashColor: Colors.amber.withOpacity(0.2),
  //                             child: Container(
  //                               padding: EdgeInsets.symmetric(vertical: 12),
  //                               decoration: BoxDecoration(
  //                                 borderRadius: BorderRadius.circular(12),
  //                                 color: Colors.amber,
  //                               ),
  //                               alignment: Alignment.center,
  //                               child: Text(
  //                                 'Search',
  //                                 style: TextStyle(
  //                                   color: Colors.black,
  //                                   fontWeight: FontWeight.bold,
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                 ],
  //               ),
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }
  void _showSearchDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> _performSearchWithUI() async {
              final query = _searchController.text.trim();
              if (query.isEmpty) return;

              setState(() => _isSearching = true);

              // Let the UI rebuild so the spinner shows
              await Future.delayed(Duration(milliseconds: 50));

              try {
                final results = await SearchService.searchManga(query);

                Navigator.of(context).pop();
                _showSearchResults(results, query);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Search failed: $e'), backgroundColor: Colors.red),
                );
              } finally {
                setState(() => _isSearching = false);
              }
            }

            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              backgroundColor: Colors.grey[900],
              insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Search Manga',
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search for manga...',
                        hintStyle: TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.grey[850],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      style: TextStyle(color: Colors.white),
                      onSubmitted: (_) => _performSearchWithUI(),
                    ),
                    SizedBox(height: 20),

                    // Yellow loading spinner
                    if (_isSearching)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Searching...', style: TextStyle(color: Colors.white70)),
                        ],
                      ),

                    if (!_isSearching)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => Navigator.pop(context),
                              borderRadius: BorderRadius.circular(12),
                              splashColor: Colors.amber.withOpacity(0.2),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white38),
                                  color: Colors.grey[850],
                                ),
                                alignment: Alignment.center,
                                child: Text('Close', style: TextStyle(color: Colors.white70)),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: _isSearching ? null : _performSearchWithUI,
                              borderRadius: BorderRadius.circular(12),
                              splashColor: Colors.amber.withOpacity(0.2),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.amber,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Search',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Colors.black,
        title: TextButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/');
          },
          child: Text(
            "ComikSan",
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.normal),
          ),
        ),

        actions: [
          if (widget.searchIcon != null)
            IconButton(onPressed: _showSearchDialog, icon: widget.searchIcon!, color: Colors.white),

          if (widget.LastReadIcon != null)
            IconButton(
              onPressed: () {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text("Marked as last read")));
              },
              icon: widget.LastReadIcon!,
              color: Colors.white,
            ),

          IconButton(
            onPressed: () {
              if (user == null) {
                Navigator.of(context).pushNamed('/login');
              } else {
                Navigator.of(context).pushNamed('/userprofile');
              }
            },
            icon: Icon(Icons.person_2_outlined, color: Colors.white),
          ),
        ],
      ),

      body: SafeArea(child: widget.body),
      bottomNavigationBar: Footersection(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
