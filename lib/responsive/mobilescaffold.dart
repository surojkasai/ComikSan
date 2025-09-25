import 'package:comiksan/pages/comick_details.dart';
import 'package:comiksan/section/Trendingsection.dart';
import 'package:comiksan/section/followingsection.dart';
import 'package:comiksan/section/footersection.dart';
import 'package:comiksan/section/readingsection.dart';
import 'package:flutter/material.dart';

class Mobilescaffold extends StatefulWidget {
  const Mobilescaffold({super.key});

  @override
  State<Mobilescaffold> createState() => _MobilescaffoldState();
}

class _MobilescaffoldState extends State<Mobilescaffold> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Followingsection(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ComickDetails()));
                },
              ),
              Trendingsection(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ComickDetails()));
                },
              ),
              Readingsection(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ComickDetails()));
                },
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: Footersection(),
    );
  }
}
