import 'package:comiksan/model/comic.dart';
import 'package:comiksan/pages/Login.dart';
import 'package:comiksan/pages/Signin.dart';
import 'package:comiksan/pages/comick_details.dart';
import 'package:comiksan/pages/download_page.dart';
import 'package:comiksan/pages/homepage.dart';
import 'package:comiksan/pages/user_profile.dart';
import 'package:comiksan/providers/comic_providers.dart';
import 'package:comiksan/util/headfooter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const MyApp());
  //runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ComicProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.light().copyWith(
          dialogTheme: DialogTheme(
            backgroundColor: Colors.white,
            titleTextStyle: TextStyle(color: Colors.black),
            contentTextStyle: TextStyle(color: Colors.black),
          ),
        ),
        darkTheme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Colors.black,
          dialogTheme: DialogTheme(
            backgroundColor: Colors.black,
            titleTextStyle: TextStyle(color: Colors.white),
            contentTextStyle: TextStyle(color: Colors.white),
          ),
        ),
        themeMode: ThemeMode.system,
        initialRoute: '/',
        routes: {
          '/': (context) => Headfooter(searchIcon: Icon(Icons.search), body: Homepage()),
          '/signin': (context) => Signin(),
          '/login': (context) => Login(),
          '/userprofile': (context) => UserProfile(),
          '/download': (context) => Downloadpage(),
          '/comic-details': (context) {
            final comic = ModalRoute.of(context)!.settings.arguments as Comic;
            return ComickDetails(comic: comic);
          },
        },
      ),
    );
  }
}
