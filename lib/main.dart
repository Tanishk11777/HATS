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
    routes: {
      '/login/': (context)=> const LoginView(),
      '/register/': (context)=> const RegisterView(),
    },
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
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
              print('User is logged in and email is verified.');
            } else if (user != null) {
              return const EmailVerification();
            }else {
              return const LoginView();
            }
            return const Text('done');
          default:
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 3, // Adjust the thickness as needed
              ),
            );
        }
      },
    );
  }
}

