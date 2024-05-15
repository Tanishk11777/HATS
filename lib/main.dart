import 'package:flutter/material.dart';
import 'package:hats/constants/routes.dart';
import 'package:hats/services/auth/auth_service.dart';
import 'package:hats/view/loginview.dart';
import 'package:hats/view/registerview.dart';
import 'package:hats/view/note/notes_view.dart';
import 'package:hats/view/note/create_update_notes_view.dart';
import 'dart:developer' as dev;

import 'package:path/path.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      notesRoute: (context)=> const NotesView(),
      UpdateNoteRoute: (context)=> const CreateUpdateNoteView(),
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
            print(user);
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