import 'package:flutter/material.dart';
//import 'package:hats/extensions/buildcontext/loc.dart';
import 'package:hats/utilities/generic_dialog.dart';

Future<void> showPasswordResetSentDialog(BuildContext context) {
  return showGenericDialog<void>(
    context: context,
    title: 'Password Reset',
    content:
    'We have now sent you a password reset link. Please check your email for more information.',
    optionsBuilder: () => {
      'OK': null,
    },
  );
}