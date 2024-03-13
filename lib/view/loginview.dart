import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hats/firebase_options.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _pass;

  @override
  void initState() {
    _email = TextEditingController();
    _pass = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Login',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.black87,
        padding: EdgeInsets.all(20), // Add padding to the container
        child: FutureBuilder(
          future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          ),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return Text('Not connected to the internet');
              case ConnectionState.waiting:
                return CircularProgressIndicator();
              case ConnectionState.done:
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Column(
                    children: [
                      TextField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Colors.white),
                          fillColor: Colors.white.withOpacity(0.2),
                          filled: true,
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _pass,
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(color: Colors.white),
                          fillColor: Colors.white.withOpacity(0.2),
                          filled: true,
                        ),
                      ),
                      SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () async {
                          final email = _email.text;
                          final pass = _pass.text;
                          try {
                            final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                              email: email,
                              password: pass,
                            );
                            print(userCredential.user);
                            // Navigator.of(context).pushNamedAndRemoveUntil(
                            //   '/home/',
                            //       (route) => false,
                            // );
                          } on FirebaseAuthException catch (e) {
                            if(e.code=='invalid-credential'){
                              print('wrong password');
                            }
                            else print('user not found');
                          }
                        },
                        child: Text('Sign in',
                          style: TextStyle(color: Colors.white),),
                          style: ElevatedButton.styleFrom(
                            elevation: 0, // Remove elevation
                            padding: EdgeInsets.zero, // Remove padding
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8), // Set button border radius
                            ),
                            primary: Colors.blue,
                          ),
                      ),SizedBox(height: 17),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              '/register/',
                                (route) => false,
                          );
                        },
                        child: Text(
                          'Create Account',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold, // Make the text bold
                          ),
                        ),
                      ),
                    ],
                  );
                }
              default:
                return Text('Unexpected ConnectionState: ${snapshot.connectionState}');
            }
          },
        ),
      ),
    );
  }
}