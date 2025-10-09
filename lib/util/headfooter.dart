import 'package:comiksan/section/footersection.dart';
import 'package:comiksan/services/search_service.dart';
import 'package:comiksan/model/comic.dart';
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
      final List<Comic> results = await SearchService.searchManga(query);

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

  Widget _buildSearchResultItem(Comic comic, BuildContext context) {
    return Card(
      color: Colors.grey[800],
      margin: EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading:
            comic.coverImageUrl != null
                ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    comic.coverImageUrl!,
                    width: 50,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 50,
                        height: 70,
                        color: Colors.grey[700],
                        child: Icon(Icons.image, color: Colors.white54),
                      );
                    },
                  ),
                )
                : Container(
                  width: 50,
                  height: 70,
                  color: Colors.grey[700],
                  child: Icon(Icons.image, color: Colors.white54),
                ),
        title: Text(
          comic.title,
          style: TextStyle(color: Colors.white, fontSize: 14),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          comic.genre ?? 'Manga',
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
        onTap: () {
          // Navigate to comic details page
          _navigateToComicDetails(comic, context);
        },
      ),
    );
  }

  void _navigateToComicDetails(Comic comic, BuildContext context) {
    // Close the search results dialog first
    Navigator.of(context).pop();

    // Navigate to comic details page
    // You'll need to create this page or use your existing one
    Navigator.pushNamed(context, '/comic-details', arguments: comic);
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.grey[900],
              title: Text('Search Manga', style: TextStyle(color: Colors.white, fontSize: 20)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for manga...',
                      hintStyle: TextStyle(color: Colors.white54),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white38),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                    onSubmitted: (_) => _performSearch(),
                  ),
                  SizedBox(height: 16),
                  if (_isSearching)
                    Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 8),
                        Text('Searching...', style: TextStyle(color: Colors.white70)),
                      ],
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Close', style: TextStyle(color: Colors.white70)),
                ),
                ElevatedButton(
                  onPressed: _isSearching ? null : _performSearch,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child:
                      _isSearching
                          ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                          : Text('Search', style: TextStyle(color: Colors.white)),
                ),
              ],
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
        backgroundColor: Colors.black,
        title: Row(
          children: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/');
              },
              child: Text(
                "ComikSan",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.normal),
              ),
            ),
          ],
        ),
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
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
      drawer: Drawer(
        backgroundColor: Colors.black,
        child: Column(
          children: [
            DrawerHeader(
              child: Text(
                'Settings',
                style: TextStyle(fontSize: 30, color: Colors.white, letterSpacing: 1),
              ),
            ),
            ListTile(
              leading: Icon(Icons.language, color: Colors.white),
              title: Text('Language', style: TextStyle(color: Colors.white)),
            ),
            ListTile(
              leading: Icon(Icons.filter, color: Colors.white),
              title: Text('Filter', style: TextStyle(color: Colors.white)),
            ),
            ListTile(
              leading: Icon(Icons.person_2_outlined, color: Colors.white),
              title: Text('Profile', style: TextStyle(color: Colors.white)),
            ),
            ListTile(
              leading: Icon(Icons.login_outlined, color: Colors.white),
              title: Text('Logout', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
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
