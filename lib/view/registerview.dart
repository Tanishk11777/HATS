import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hats/firebase_options.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
          'New User',
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
                      SizedBox(height: 25),
                      SizedBox(width: 170,
                        child: ElevatedButton(
                          onPressed: () async {
                            final email = _email.text;
                            final pass = _pass.text;
                            try {
                              final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                                email: email,
                                password: pass,
                              );
                              print(userCredential.user);
                            } on FirebaseAuthException catch (e) {
                              if(e.code=='weak-password'){
                                print('weak password');
                              }else if(e.code=='email-already-in-use'){
                                print('email already registered');
                              } else{
                                  print('error try again later');
                              }
                            }
                          },
                          child: Text('Create Account',
                            style: TextStyle(color: Colors.white),),
                            style: ElevatedButton.styleFrom(
                              elevation: 0, // Remove elevation
                              padding: EdgeInsets.zero, // Remove padding
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8), // Set button border radius
                              ),
                              primary: Colors.blue,
                            ),
                        ),
                      ),SizedBox(height: 17),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            '/login/',
                                (route) => false,
                          );
                        },
                        child: Text(
                          'Already registerd?',
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

class EmailVerification extends StatefulWidget {
  const EmailVerification({Key? key}) : super(key: key);

  @override
  _EmailVerificationState createState() => _EmailVerificationState();
}

class _EmailVerificationState extends State<EmailVerification> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Verification',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.black87, // Set the entire body to black87
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Please verify your email address:",
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final user = FirebaseAuth.instance.currentUser;
                  await user?.sendEmailVerification();
                },
                child: Text(
                  "Send Email Verification",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 0, // Remove elevation
                  padding: EdgeInsets.zero, // Remove padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Set button border radius
                  ),
                  primary: Colors.blue,
                ),
              ),
              Expanded(child: SizedBox()), // This widget expands to fill available space
            ],
          ),
        ),
      ),
    );
  }
}

