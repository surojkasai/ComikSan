import 'package:comiksan/pages/homepage.dart';
import 'package:comiksan/util/headfooter.dart';
import 'package:comiksan/util/sign_in_google.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>(); // for form validation

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // bool Login = true;

  // void togglePage() {
  //   setState(() {
  //     Login = !Login;
  //   });
  // }

  // void wrongEmailMessage() {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         backgroundColor: Colors.grey[900],
  //         title: Text('Wrong email', style: TextStyle(color: Colors.white)),
  //       );
  //     },
  //   );
  // }

  // void wrongPasswordMessage() {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(backgroundColor: Colors.white, title: Text('Wrong password'));
  //     },
  //   );
  // }

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(backgroundColor: Colors.white, title: Text(message));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Headfooter(
      topicon: Icon(Icons.search),
      body: Scaffold(
        backgroundColor: Colors.black,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Form(
              key: _formKey, // Form validation
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text('Login', style: TextStyle(color: Colors.white, fontSize: 25)),
                  ),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: passwordController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.password),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  TextButton(onPressed: () {}, child: Text('Forgot password?')),
                  TextButton(
                    onPressed: () async {
                      try {
                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                          email: emailController.text.trim(),
                          password: passwordController.text.trim(),
                        );
                        //this works
                        Navigator.of(context).pushReplacementNamed('/');
                        // Navigate or show success
                      } on FirebaseAuthException catch (e) {
                        print('Firebase Error Code: ${e.code}');
                        // Handle error (e.g., show Snackbar)
                        String message = '';
                        switch (e.code) {
                          case 'user-not-found':
                            message = 'No user found with this email.';
                            break;
                          case 'wrong-password':
                            message = 'Incorrect password. Try again.';
                            break;
                          case 'invalid-credential':
                            message = 'Email or password is incorrect.';
                            break;
                          default:
                            message = 'An unexpected error occurred: ${e.message}';
                        }

                        //this is for testing as the showdialg was not working prev
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   SnackBar(
                        //     content: Text(message, style: TextStyle(color: Colors.white)),
                        //     backgroundColor: Colors.red,
                        //   ),
                        // );
                        showErrorMessage(message);
                      }
                    },

                    child: Text('Sign-in', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 10),
                  Text('Or continue with', style: TextStyle(color: Colors.deepPurple)),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: IconButton(
                          onPressed: () async {
                            try {
                              // 1. Dismiss any keyboard or input focus
                              FocusScope.of(context).unfocus();
                              final userCredential = await signInWithGoogle();
                              if (userCredential.user != null) {
                                Navigator.of(context).pushNamed('/');
                              }
                              print("Signed in: ${userCredential.user?.displayName}");
                            } catch (e) {
                              print("Error: $e");
                            }
                          },
                          icon: Image.asset(
                            'assets/images/googlemulti.png',
                            width: 50,
                            height: 40,
                            colorBlendMode: BlendMode.src,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Container(
                        child: IconButton(
                          onPressed: () {},
                          icon: Image.asset(
                            'assets/images/applerainbow.png',
                            width: 50,
                            height: 40,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/signin');
                    },
                    child: Text('Not a member ? Sign in'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
