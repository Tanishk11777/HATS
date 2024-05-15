import 'package:flutter/material.dart';
import 'package:hats/utilities/generic_dialog.dart';

Future<bool> showLogOutDialog(BuildContext context) {
  return showGenericDialog<bool>(
    context: context,
    title: 'Log out',
    content: 'Want to logout?',
    optionsBuilder: () => {
      'Cancel': false,
      'Log out': true,
    },
  ).then(
        (value) => value ?? false,
  );
}