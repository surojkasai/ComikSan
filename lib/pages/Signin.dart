import 'package:comiksan/util/headfooter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Signin extends StatefulWidget {
  const Signin({super.key});

  @override
  State<Signin> createState() => _UserProfileState();
}

class _UserProfileState extends State<Signin> {
  final _formKey = GlobalKey<FormState>(); // for form validation

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void showErrorMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text('Enter same password', style: TextStyle(color: Colors.white)),
        );
      },
    );
  }

  @override
  TextEditingController confirmpasswordController = TextEditingController();
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
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(
                      'Create a new Account',
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),
                  ),
                  TextFormField(
                    controller: emailController,
                    style: TextStyle(color: Colors.white),
                    //keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Enter you mail',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: passwordController,
                    style: TextStyle(color: Colors.white),

                    decoration: InputDecoration(
                      labelText: '  Enter password',
                      prefixIcon: Icon(Icons.password),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: confirmpasswordController,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: '  Confirm password',
                      prefixIcon: Icon(Icons.password),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  //TextButton(onPressed: () {}, child: Text('Forgot password?')),
                  TextButton(
                    onPressed: () async {
                      //try creating the user
                      try {
                        if (passwordController.text == confirmpasswordController.text) {
                          await FirebaseAuth.instance.createUserWithEmailAndPassword(
                            email: emailController.text,
                            password: passwordController.text,
                          );
                          Navigator.of(context).pushReplacementNamed('/userprofile');
                        } else {
                          showErrorMessage();
                        }
                      } on FirebaseAuthException catch (e) {
                        print('error: $e');
                      }
                    },
                    child: Text('Sign-Up', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 10),
                  Text('Or continue with', style: TextStyle(color: Colors.deepPurple)),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: IconButton(
                          onPressed: () {},
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
                      Navigator.of(context).pushNamed('/login');
                    },
                    child: Text('Already a member ? Login'),
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
