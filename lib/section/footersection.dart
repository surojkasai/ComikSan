import 'package:comiksan/pages/download_page.dart';
import 'package:flutter/material.dart';

class Footersection extends StatefulWidget {
  const Footersection({super.key});

  @override
  State<Footersection> createState() => _FootersectionState();
}

class _FootersectionState extends State<Footersection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
            icon: Icon(Icons.home, color: Colors.white),
          ),

          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Downloadpage(onTap: () {})),
              );
            },
            icon: Icon(Icons.download),
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
