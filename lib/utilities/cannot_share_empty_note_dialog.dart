import 'package:flutter/cupertino.dart';
import 'package:hats/utilities/generic_dialog.dart';

Future<void> shoeCannotShareEmptyNoteDialog(BuildContext context){
  return showGenericDialog<void>(context: context, title: 'Sharing', content: 'You Cannot share an empty note!', optionsBuilder:()=>{
    'OK': null,
  },);
}