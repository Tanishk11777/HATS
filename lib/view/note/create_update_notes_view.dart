import 'package:flutter/material.dart';
import 'package:hats/services/auth/auth_service.dart';
import 'package:hats/services/cloud/cloud_storage_constants.dart';
import 'package:hats/services/crud/notes_service.dart';
import 'package:hats/utilities/cannot_share_empty_note_dialog.dart';
import 'package:hats/utilities/generics/get_arguments.dart';
import 'package:hats/services/cloud/cloud_note.dart';
import 'package:hats/services/cloud/cloud_storage_exceptions.dart';
import 'package:hats/services/cloud/firebase_cloud_storage.dart';
import 'package:share_plus/share_plus.dart';

class CreateUpdateNoteView extends StatefulWidget {
  const CreateUpdateNoteView({super.key});

  @override
  State<CreateUpdateNoteView> createState() => _CreateUpdateNoteViewState();
}

class _CreateUpdateNoteViewState extends State<CreateUpdateNoteView> {
  CloudNote? _note;
  late final FirebaseCloudStorage _notesService;
  late final TextEditingController _textController;

  @override
  void initState(){
    _notesService=FirebaseCloudStorage();
    _textController=TextEditingController();
    super.initState();
  }

  void _textControllerListener() async{
    final note=_note;
    if(note==null){
      return;
    }
    final text=_textController.text;
    await _notesService.updateNote(documentId: note.documentId, text: text);
  }

  void _setupTextListener(){
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  Future<CloudNote> createOrGetExistingNote(BuildContext context) async{

    final widgetNote=context.getArgument<CloudNote>();

    if(widgetNote!=null){
      _note=widgetNote;
      _textController.text=widgetNote.text;
      return widgetNote;
    }

    final existingNote=_note;
    if(existingNote!=null){
      return existingNote;
    }
    final currentUser=AuthService.firebase().currentUser!;
    final userId = currentUser.id;
    //final owner = await _notesService.getUser(email: email);
    final newNote= await _notesService.createNewNote(ownerUserId: userId);
    _note=newNote;
    return newNote;
  }

  void _deleteIfEmpty(){
    final note= _note;
    if(_textController.text.isEmpty && note != null){
      _notesService.deleteNote(documentId: note.documentId);
    }
  }

  void _saveNoteIfTextNotEmpty() async{
    final note=_note;
    final text = _textController.text;
    if(note!=null && text.isNotEmpty){
      await _notesService.updateNote(documentId: note.documentId, text: text);
    }
  }

  @override
  void dispose() {
    _deleteIfEmpty();
    _saveNoteIfTextNotEmpty();
    _textController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.white70, //change your color here
          ),
          title: Text(
            'New Note',
           style: TextStyle(
            color: Colors.white,
            ),
          ),
          actions: [
            IconButton(onPressed: ()async{
              final text=_textController.text;
              if(_note==null || text.isEmpty){
                await shoeCannotShareEmptyNoteDialog(context);
              }else{
                Share.share(text);
              }
            }, icon: const Icon(Icons.share_outlined),),
          ],
          backgroundColor: Colors.black,
          centerTitle: true,
        ),
        body: FutureBuilder(
          future: createOrGetExistingNote(context),
          builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  print(snapshot.data);
                  if (snapshot.hasData && snapshot.data != null) {
                    _setupTextListener();
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _textController,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: const InputDecoration(
                          hintText: 'Start typing your note...',
                        ),
                      ),
                    );
                  } else {
                    return Text('Error: Unable to create new note.');
                  }
                default:
                  return const CircularProgressIndicator(strokeWidth: 3,);
              }
            },
        ),
    );
  }
}
