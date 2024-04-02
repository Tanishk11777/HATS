import 'package:flutter/material.dart';
import 'package:hats/constants/routes.dart';
import 'package:hats/services/auth/auth_service.dart';
import 'package:hats/view/loginview.dart';
import 'package:hats/view/registerview.dart';
import 'dart:developer' as dev;

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
      loginRoute: (context)=> const LoginView(),
      registerRoute: (context)=> const RegisterView(),
      homeRoute: (context)=> const HomePage(),
      emailveriRoute: (context)=> const EmailVerification(),
    },
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red));
            }
            final user = AuthService.firebase().currentUser;
            if (user != null && user.isEmailVerified) {
              print('User is logged in and email is verified.');
              return const NotesView();
            } else if (user != null) {
              return const EmailVerification();
            }else {
              return const LoginView();
            }

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