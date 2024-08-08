import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  final String title;
  final String content;

  ConfirmationDialog({
    required this.onConfirm,
    this.title = "Delete Confirmation",
    this.content = "Are you sure you want to delete this item?",
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Icon(Icons.warning_amber, color: Colors.red),
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          child: Text("Cancel"),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text("Delete"),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
