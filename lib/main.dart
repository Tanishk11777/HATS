import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hats/view/loginview.dart';
import 'package:hats/view/registerview.dart';
import 'package:hats/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Hats',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: const HomePage(),
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'H.A.T.S.',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Container(
        color: Colors.black87, // Changed to set the background completely black
        child: Center( // Center widget added to center the text
          child: Padding(
            padding: EdgeInsets.all(20),
            child: FutureBuilder(
              future: Firebase.initializeApp(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.done:
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red));
                    }
                    final user = FirebaseAuth.instance.currentUser;
                    print(user);
                    if (user != null && user.emailVerified) {
                      return Text('User is logged in and email is verified.', style: TextStyle(color: Colors.green));
                    } else {
                      return const EmailVerification();
                    }
                  default:
                    return Text('Loading...');
                }
              },
            ),
          ),
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