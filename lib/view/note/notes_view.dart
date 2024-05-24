import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hats/constants/routes.dart';
import 'package:hats/enums/menu_action.dart';
import 'package:hats/services/auth/auth_service.dart';
import 'package:hats/services/auth/bloc/auth_bloc.dart';
import 'package:hats/services/auth/bloc/auth_event.dart';
import 'package:hats/services/cloud/cloud_note.dart';
import 'package:hats/services/cloud/firebase_cloud_storage.dart%20';
//import 'package:hats/services/crud/notes_service.dart';
import 'package:hats/utilities/logout_dialog.dart';
import 'package:hats/view/note/notes_listview.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final FirebaseCloudStorage _notesService;
  String get userId=>AuthService.firebase().currentUser!.id;
  @override
  void initState(){
    _notesService=FirebaseCloudStorage();
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
                UpdateNoteRoute
            );
          }, icon: const Icon(Icons.add,color: Colors.white70,)),
          PopupMenuButton<MenuAction>(icon: Icon(
            Icons.logout,
            color: Colors.white70,
          ),onSelected:(value) async {
            switch(value){
              case MenuAction.logout:
                final shouldLogout=await showLogOutDialog(context);
                if(shouldLogout){
                  context.read<AuthBloc>().add(const AuthEventLogOut());
                }
                break;
            }
          },
            itemBuilder: (context){
              return const [
                const PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Icon(Icons.logout),
                      ),
                      const Text(
                        'Logout',
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ];
            },
          )
        ],
        backgroundColor: Colors.black,
        centerTitle: true,
      ),body:StreamBuilder(
      stream: _notesService.allNotes(ownerUserId: userId),
      builder: ((context, snapshot) {
        switch(snapshot.connectionState){
          case ConnectionState.waiting:
          case ConnectionState.active:
            if(snapshot.hasData){
              final allNotes=snapshot.data as Iterable<CloudNote>;
              return NotesListView(notes: allNotes, onDeleteNote: (note)async{
                await _notesService.deleteNote(documentId: note.documentId);
              },
                onTap: (note){
                  Navigator.of(context).pushNamed(
                    UpdateNoteRoute,
                    arguments: note,
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
    ),
    );
  }
}
