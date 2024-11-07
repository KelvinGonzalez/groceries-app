import 'package:flutter/material.dart';

class ConfirmationAlert extends StatelessWidget {
  final String question;

  const ConfirmationAlert({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(question),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text("No")),
        TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text("Yes"))
      ],
    );
  }
}
