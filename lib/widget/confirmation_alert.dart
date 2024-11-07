import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groceries_app/logic/state_cubit.dart';
import 'package:groceries_app/model/translated_text.dart';

class ConfirmationAlert extends StatelessWidget {
  final String question;

  const ConfirmationAlert({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<StateCubit>();
    return AlertDialog(
      title: Text(question),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: Text(cubit.getTranslation(TranslatedText.no))),
        TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: Text(cubit.getTranslation(TranslatedText.yes)))
      ],
    );
  }
}
