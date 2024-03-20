import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hats/constants/routes.dart';
import 'package:hats/view/loginview.dart';
import 'package:hats/view/registerview.dart';
import 'package:hats/firebase_options.dart';
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

enum MenuAction{ logout }

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Your Notes',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
          actions: [
            PopupMenuButton<MenuAction>(onSelected:(value) async {
              switch(value){
                case MenuAction.logout:
                  final shouldlogout=await showLogOutDialog(context);
                  if(shouldlogout){
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      homeRoute,
                          (route) => false,
                    );
                  }
                  break;
              }
            },
              itemBuilder: (constext){
              return const [
                const PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Logout'),
                ),
              ];
             },
            )
          ],
        backgroundColor: Colors.black,
        centerTitle: true,
      ),body:const Text('Hello World'),
    );
  }
}

Future<bool> showLogOutDialog(BuildContext context) async {
  bool? result = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Logout"),
        content: Text("Are you sure you want to logout?"),
        actions: <Widget>[
          TextButton(
            child: Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          TextButton(
            child: Text("Logout"),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    },
  );
  return result ?? false;
}



