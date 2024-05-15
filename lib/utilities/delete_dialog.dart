import 'package:flutter/material.dart';
import 'package:hats/utilities/generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Delete',
    content: 'Want to Delete?',
    optionsBuilder: () => {
      'Cancel': false,
      'Yes': true,
    },
  ).then(
        (value) => value ?? false,
  );
}