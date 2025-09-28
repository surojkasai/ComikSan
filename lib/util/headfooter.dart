import 'package:comiksan/pages/Login.dart';
import 'package:comiksan/section/footersection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Headfooter extends StatefulWidget {
  final Widget body;
  final Widget? LastReadIcon;
  final Widget? searchIcon;

  const Headfooter({
    super.key,
    this.searchIcon,
    this.LastReadIcon,
    required this.body, //required this.footer
  });

  @override
  State<Headfooter> createState() => _HeadfooterState();
}

class _HeadfooterState extends State<Headfooter> {
  // void searchShowDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return searchDialog();
  //     },
  //   );
  // }
  final user = FirebaseAuth.instance.currentUser;
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
                icon: Icon(Icons.menu, color: Colors.white), // ✅ Set the icon color manually
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
        actions: [
          if (widget.searchIcon != null)
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Search'),
                      content: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search Comicks',
                          //hintStyle: TextStyle(color: Colors.black87),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white38),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('close'),
                        ),
                        TextButton(onPressed: () {}, child: Text('search')),
                      ],
                    );
                  },
                );
              },
              icon: widget.searchIcon!,
              color: Colors.white,
            ),

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
                // Not logged in, navigate to Login/Register
                Navigator.of(context).pushNamed('/login');
              } else {
                // Logged in, navigate to User Profile
                Navigator.of(context).pushNamed('/userprofile');
              }
              //Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
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
              leading: Icon(Icons.language),
              title: Text('language'),
              textColor: Colors.white,
            ),
            ListTile(leading: Icon(Icons.filter), title: Text('Filter'), textColor: Colors.white),
            ListTile(
              leading: Icon(Icons.person_2_outlined),
              title: Text('Profile'),
              textColor: Colors.white,
            ),
            ListTile(
              leading: Icon(Icons.login_outlined),
              title: Text('Logout'),
              textColor: Colors.white,
            ),
          ],
        ),
      ),
      body: SafeArea(child: widget.body),
      //bottomNavigationBar: Footersection(),
    );
  }
}
