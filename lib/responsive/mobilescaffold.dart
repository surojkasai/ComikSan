import 'package:comiksan/providers/comic_providers.dart';
import 'package:comiksan/section/followingsection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Mobilescaffold extends StatefulWidget {
  const Mobilescaffold({super.key});

  @override
  State<Mobilescaffold> createState() => _MobilescaffoldState();
}

class _MobilescaffoldState extends State<Mobilescaffold> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Load comics when mobilescaffold initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final comicProvider = Provider.of<ComicProvider>(context, listen: false);
      comicProvider.loadComics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [Followingsection()]),
        ),
      ),
    );
  }
}
