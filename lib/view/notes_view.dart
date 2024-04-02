import 'package:flutter/material.dart';
import 'package:hats/constants/routes.dart';
import 'package:hats/enums/menu_action.dart';
import 'package:hats/services/auth/auth_service.dart';

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
                  await AuthService.firebase().logout();
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