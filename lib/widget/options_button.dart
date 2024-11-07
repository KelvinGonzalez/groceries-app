import 'package:flutter/material.dart';
import 'package:groceries_app/widget/options_menu.dart';

class OptionsButton extends StatelessWidget {
  const OptionsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: IconButton(
          onPressed: () {
            showDialog(
                context: context,
                useRootNavigator: false,
                builder: (context) => const OptionsMenu());
          },
          icon: const Icon(Icons.settings)),
    );
  }
}
