import 'package:flutter/material.dart';

Future<bool> showConfirmDialog({
  required BuildContext context,
  required String title,
  required String content,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );

  return result ?? false;
}
