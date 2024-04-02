import 'package:flutter/cupertino.dart';
import 'package:hats/services/crud/crud_exceptions.dart';
import 'package:hats/services/crud/notes_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;


class NotesService {

  Database? _db;

  Future<DatabaseNote> updateNote({required DatabaseNote note,required String text,})async{
    final db=_getDatabaseOrThrow();
    await getNote(id: note.id);

    final updateCount=await db.update(noteTable,{
      textColumn: text,
      isSyncedWithCloudColumn: 0,
    });

    if(updateCount==0){
      throw CouldNotUpdateNote();
    }else{
      return await getNote(id: note.id);
    }

  }

  Future<Iterable<DatabaseNote>> getAllNotes()async{
    final db=_getDatabaseOrThrow();
    final notes=await db.query(noteTable);

    return notes.map((e) => DatabaseNote.fromRow(notes.first));

  }

  Future<DatabaseNote> getNote({required int id})async{
    final db=_getDatabaseOrThrow();
    final notes=await db.query(noteTable, limit: 1,where: 'id=?',whereArgs: [id],);
    if(notes.isEmpty){
      throw CouldNotFindNote();
    }else{
      return DatabaseNote.fromRow(notes.first);
    }
  }

  Future<int> deleteAllNotes()async{
    final db=_getDatabaseOrThrow();
    return await db.delete(noteTable);
  }

  Future<void> deleteNote({required int id}) async{
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(noteTable, where: 'id=?', whereArgs: [id],);
    if(deleteCount!=1){
      throw CouldNotDeleteNote();
    }
  }

  Future<DatabaseNote> createNote({required Databaseuser owner})async{
    final db=_getDatabaseOrThrow();
    final dbUser=await getUser(email: owner.email);
    if(dbUser!=owner){
      throw CouldNotFindUser();
    }
    const text='';
    final noteId=await db.insert(noteTable,{
      userIdColumn: owner.id,
      textColumn: text,
      isSyncedWithCloudColumn: 1,
    });

    final note=DatabaseNote(id: noteId, userId: owner.id, text: text, isSyncedWithWithCloud: true,);
    return note;
  }
  
  Future<Databaseuser> getUser({required String email})async{
    final db=_getDatabaseOrThrow();
    final results=await db.query(userTable,limit: 1,where: 'email=?',whereArgs: [email.toLowerCase()]);
    if(results.isEmpty){
      throw CouldNotFindUser();
    }else{
      return Databaseuser.fromRow(results.first);
    }
    }

  Future<Databaseuser> createUser({required String email})async{
    final db= _getDatabaseOrThrow();
    final results=await db.query(userTable,limit: 1,where: 'email=?',whereArgs: [email.toLowerCase()]);
    if(results.isNotEmpty){
      throw UserAlreadyExists();
    }

    final userId=await db.insert(userTable, {
      emailColumn: email.toLowerCase(),
    });
    return Databaseuser(id: userId, email: email);
  }

  Future<void> deleteUser({required String email}) async{
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(userTable, where: 'email=?', whereArgs: [email.toLowerCase()],);
    if(deleteCount!=1){
      throw CouldNotDelete();
    }
  }

  Database _getDatabaseOrThrow(){
    final db=_db;
    if(db==null){
      throw NoDatabaseOpen();
    }else{
      return db;
    }
  }

  Future<void> close()async{
    final db =_db;
    if(db==null){
      throw NoDatabaseOpen();
    }else{
      await db.close();
      _db=null;
    }
  }

  Future<void> open() async{
    if(_db!=null){
      throw DatabaseAlreadyOpen();
    }
    try{
      final docsPath=await getApplicationDocumentsDirectory();
      final dbPath=join(docsPath.path, dbName);
      final db= await openDatabase(dbPath);
      _db=db;

      await db.execute(createUserTable);



      await db.execute(createNoteTable);

    }on MissingPlatformDirectoryException{
      throw UnableToGet();
    }
  }
}

@immutable
class Databaseuser{
  final int id;
  final String email;

  const Databaseuser({required this.id,required  this.email});

  Databaseuser.fromRow(Map<String, Object?> map) : id=map[idColumn] as int, email=map[emailColumn] as String;

  @override
  String toString() => 'Person, ID=$id, email=$email';

  @override bool operator==(covariant Databaseuser other) => id  == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithWithCloud;


  DatabaseNote({required this.id, required this.userId, required this.text, required this.isSyncedWithWithCloud});
  DatabaseNote.fromRow(Map<String, Object?> map) : id=map[idColumn] as int, userId=map[userIdColumn] as int,
  text=map[textColumn]as String,
  isSyncedWithWithCloud=(map[isSyncedWithCloudColumn] as int)==1?true:false;

  @override
  String toString()=> 'Note, ID =$id, userId=$userId,isSynced=$isSyncedWithWithCloud';

  @override bool operator==(covariant DatabaseNote other) => id  == other.id;

  @override
  int get hashCode => id.hashCode;

}

const dbName='notes.db';
const noteTable='note';
const userTable='user';
const idColumn = "id";
const emailColumn = 'email';
const userIdColumn = 'user_id';
const textColumn = 'text';
const isSyncedWithCloudColumn='is_synced_with_cloud';
const createNoteTable='''
        CREATE TABLE IF NOT EXISTS "note" (
        "id"	INTEGER NOT NULL,
        "user_id"	INTEGER NOT NULL,
        "text"	TEXT,
        "is_synced_with_cloud"	INTEGER DEFAULT 0,
        FOREIGN KEY("user_id") REFERENCES "user"("ID"),
        PRIMARY KEY("id" AUTOINCREMENT)
      );''';
const createUserTable='''
        CREATE TABLE IF NOT EXISTS "user" (
	      "ID"	INTEGER NOT NULL,
	      "email"	TEXT NOT NULL UNIQUE,
	      PRIMARY KEY("ID" AUTOINCREMENT)
      );''';