import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groceries_app/logic/shared_preferences_controller.dart';
import 'package:groceries_app/logic/state_cubit.dart';

class DarkModeSwitch extends StatelessWidget {
  const DarkModeSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StateCubit, AppState>(
        builder: (context, state) => Row(children: [
              Icon(state.isDarkMode ? Icons.light_mode : Icons.dark_mode),
              Switch(
                  value: state.isDarkMode,
                  onChanged: (value) {
                    context.read<StateCubit>().setDarkMode(value);
                    setDarkMode(value);
                  }),
            ]));
  }
}
