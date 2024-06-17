import 'package:flutter/cupertino.dart';
import 'package:hats/extensions/buildcontext/loc.dart';
import 'package:hats/utilities/generic_dialog.dart';

Future<void> shoeCannotShareEmptyNoteDialog(BuildContext context){
  return showGenericDialog<void>(context: context, title: context.loc.sharing, content: context.loc.cannot_share_empty_note_prompt, optionsBuilder:()=>{
  context.loc.ok: null,
  },);
}