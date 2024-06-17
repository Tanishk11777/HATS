import 'package:flutter/cupertino.dart';
import 'package:hats/extensions/buildcontext/loc.dart';
import 'package:hats/utilities/generic_dialog.dart';

Future<void> showErrorDialog(
    BuildContext context,
    String text,
    ) {
  return showGenericDialog<void>(
    context: context,
    title: context.loc.generic_error_prompt,
    content: text,
    optionsBuilder: () => {
    context.loc.ok: null,
    },
  );
}