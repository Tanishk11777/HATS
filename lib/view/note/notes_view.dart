import 'package:flutter/material.dart';
import 'package:hats/constants/routes.dart';
import 'package:hats/enums/menu_action.dart';
import 'package:hats/services/auth/auth_service.dart';
import 'package:hats/services/crud/notes_service.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final NotesService _notesService;
  String get userEmail=>AuthService.firebase().currentUser!.email;
  @override
  void initState(){
    _notesService=NotesService();
    super.initState();
  }


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
          IconButton(onPressed: (){
            Navigator.of(context).pushNamed(
                newNoteRoute
            );
          }, icon: const Icon(Icons.add,color: Colors.white70,)),
          PopupMenuButton<MenuAction>(icon: Icon(
            Icons.read_more_outlined,
            color: Colors.white70,
          ),onSelected:(value) async {
            switch(value){
              case MenuAction.logout:
                final shouldLogout=await showLogOutDialog(context);
                if(shouldLogout){
                  await AuthService.firebase().logout();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    homeRoute,
                        (route) => false,
                  );
                }
                break;
            }
          },
            itemBuilder: (context){
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
      ),body:FutureBuilder(
      future: _notesService.getOrCreateUser(email: userEmail),
      builder: (context,snapshot){
        switch(snapshot.connectionState){
          case ConnectionState.done:
            return StreamBuilder(
                stream: _notesService.allNotes,
                builder: ((context, snapshot) {
                  switch(snapshot.connectionState){
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                      if(snapshot.hasData){
                        //return const Text('All correct');
                        final allNotes=snapshot.data as List<DatabaseNote>;
                        return ListView.builder(
                          itemCount: allNotes.length,
                          itemBuilder: (context, index){
                            final note=allNotes[index];
                            return ListTile(
                             title:Text(
                              note.text,
                              maxLines: 1,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                            ),
                            );
                          },
                        );
                      }else{
                        return const CircularProgressIndicator();
                      }
                    default:
                      return const CircularProgressIndicator();
                  }
                }),
            );
          default:
            return const CircularProgressIndicator();
        }
      },
    ),
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