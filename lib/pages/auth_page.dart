// import 'package:comiksan/pages/Login.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class AuthPage extends StatefulWidget {
//   const AuthPage({super.key});

//   @override
//   _AuthPageState createState() => _AuthPageState();
// }

// class _AuthPageState extends State<AuthPage> {
//   bool _redirected = false;

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<User?>(
//       stream: FirebaseAuth.instance.authStateChanges(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.active) {
//           final user = snapshot.data;
//           if (user != null) {
//             if (!_redirected) {
//               _redirected = true;
//               // Delay navigation after build complete
//               WidgetsBinding.instance.addPostFrameCallback((_) {
//                 Navigator.of(context).pushReplacementNamed('/userprofile');
//               });
//             }
//             return Center(child: CircularProgressIndicator());
//           } else {
//             return Login();
//           }
//         }
//         return Center(child: CircularProgressIndicator());
//       },
//     );
//   }
// }
