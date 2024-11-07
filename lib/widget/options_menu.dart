import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groceries_app/logic/shared_preferences_controller.dart';
import 'package:groceries_app/logic/state_cubit.dart';
import 'package:groceries_app/model/translated_text.dart';

class OptionsMenu extends StatelessWidget {
  const OptionsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StateCubit, AppState>(builder: (context, state) {
      final cubit = context.read<StateCubit>();
      final darkModeOn = state.isDarkMode;
      final languageOn = state.language == Language.spanish;
      return AlertDialog(
        title: Text(cubit.getTranslation(TranslatedText.options)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  cubit.getTranslation(TranslatedText.light),
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          !darkModeOn ? FontWeight.bold : FontWeight.normal),
                ),
                const Text(" / "),
                Text(
                  cubit.getTranslation(TranslatedText.dark),
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          darkModeOn ? FontWeight.bold : FontWeight.normal),
                ),
                Expanded(child: Container()),
                Switch(
                    value: darkModeOn,
                    onChanged: (value) {
                      cubit.setDarkMode(value);
                      setDarkMode(value);
                    })
              ],
            ),
            Row(
              children: [
                Text(
                  "English",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          !languageOn ? FontWeight.bold : FontWeight.normal),
                ),
                const Text(" / "),
                Text(
                  "Español",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          languageOn ? FontWeight.bold : FontWeight.normal),
                ),
                Expanded(child: Container()),
                Switch(
                    value: languageOn,
                    onChanged: (value) {
                      final language =
                          value ? Language.spanish : Language.english;
                      cubit.setLanguage(language);
                      setLanguage(language);
                    })
              ],
            )
          ],
        ),
      );
    });
  }
}
