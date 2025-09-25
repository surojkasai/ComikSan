import 'package:comiksan/responsive/mobilescaffold.dart';
import 'package:comiksan/responsive/responsivelayout.dart';
import 'package:comiksan/responsive/tabscaffold.dart';
import 'package:comiksan/responsive/webscaffold.dart';
import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return Responsivelayout(
      mobileScaffold: Mobilescaffold(),
      tabScaffold: Tabscaffold(),
      webScaffold: Webscaffold(),
    );
  }
}
