import 'package:comiksan/util/headfooter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController updatepasswordController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser!;

  Future<void> signOutUser() async {
    // Sign out from Firebase
    await FirebaseAuth.instance.signOut();

    // Also sign out from Google (to fully disconnect session)
    final googleSignIn = GoogleSignIn();
    if (await googleSignIn.isSignedIn()) {
      await googleSignIn.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Headfooter(
      // topicon: Icon(Icons.search),
      body: Scaffold(
        backgroundColor: Colors.black,
        body: SingleChildScrollView(
          child: Column(
            children: [
              IconButton(onPressed: () {}, icon: Icon(Icons.person_2_outlined, size: 100)),
              // TextFormField(
              //   controller: emailController,
              //   keyboardType: TextInputType.emailAddress,
              //   style: TextStyle(color: Colors.white),
              //   decoration: InputDecoration(
              //     labelText: 'Email',
              //     prefixIcon: Icon(Icons.email),
              //     border: OutlineInputBorder(),
              //   ),
              // ),
              Text('logged in as ' + user.email!, style: TextStyle(color: Colors.white)),
              SizedBox(height: 10),
              //Text('Password chan '),
              TextFormField(
                controller: updatepasswordController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.password),
                  border: OutlineInputBorder(),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () async {
                      try {
                        await user.updatePassword(updatepasswordController.text);
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('Password updated successfully')));
                      } on FirebaseAuthException catch (e) {
                        if (e.code == 'requires-recent-login') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Please re-authenticate and try again')),
                          );
                          // Navigate to login page or show re-auth dialog
                        } else {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
                        }
                      }
                    },
                    child: Text('Change Password'),
                  ),
                ],
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () async {
                  await signOutUser();
                  Navigator.of(context).pushReplacementNamed('/');
                },
                style: TextButton.styleFrom(
                  side: BorderSide(width: 1), // <-- border here
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // optional
                  ),
                ),
                child: Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
