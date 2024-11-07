import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:groceries_app/logic/firebase_controller.dart";
import "package:groceries_app/logic/shared_preferences_controller.dart";
import "package:groceries_app/logic/state_cubit.dart";
import "package:groceries_app/logic/utils.dart";
import "package:groceries_app/model/translated_text.dart";
import "package:groceries_app/widget/options_button.dart";
import "package:groceries_app/widget/household_card.dart";

class HouseholdsPage extends StatelessWidget {
  const HouseholdsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StateCubit, AppState>(builder: (context, state) {
      final cubit = context.read<StateCubit>();
      return Scaffold(
        appBar: AppBar(
          title: Text(cubit.getTranslation(TranslatedText.households)),
          actions: const [OptionsButton()],
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: state.households
                .map((household) => HouseholdCard(household: household))
                .toList(),
          ),
        ),
        floatingActionButton: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
                heroTag: "btn1",
                onPressed: () {
                  final controller = TextEditingController();
                  showDialog(
                      context: context,
                      useRootNavigator: false,
                      builder: (context) => AlertDialog(
                              title: Text(cubit.getTranslation(
                                  TranslatedText.createHousehold)),
                              content: TextField(
                                  controller: controller,
                                  onSubmitted: (value) =>
                                      _createHousehold(context, cubit, value),
                                  decoration: InputDecoration(
                                      hintText: cubit.getTranslation(
                                          TranslatedText.enterName))),
                              actions: [
                                IconButton(
                                    onPressed: () => _createHousehold(
                                        context, cubit, controller.text),
                                    icon: const Icon(Icons.add))
                              ]));
                },
                child: const Icon(Icons.add)),
            const SizedBox(width: 12),
            FloatingActionButton(
                heroTag: "btn2",
                onPressed: () async {
                  final controller = TextEditingController();
                  showDialog(
                      context: context,
                      useRootNavigator: false,
                      builder: (context) => AlertDialog(
                              title: Text(cubit.getTranslation(
                                  TranslatedText.joinHousehold)),
                              content: TextField(
                                  controller: controller,
                                  onSubmitted: (value) =>
                                      _joinHousehold(context, cubit, value),
                                  decoration: InputDecoration(
                                      hintText: cubit.getTranslation(
                                          TranslatedText.enterAccessCode))),
                              actions: [
                                IconButton(
                                    onPressed: () => _joinHousehold(
                                        context, cubit, controller.text),
                                    icon: const Icon(Icons.download))
                              ]));
                },
                child: const Icon(Icons.download)),
          ],
        ),
      );
    });
  }

  Future<void> _createHousehold(
      BuildContext context, StateCubit cubit, String name) async {
    final trimmedName = name.trim();
    if (trimmedName.isNotEmpty) {
      final household =
          await FirebaseController.instance.createHousehold(trimmedName);
      await addHouseholdId(household.id);
      cubit.addHousehold(household);
    } else {
      sendSnackBar(
          context, cubit.getTranslation(TranslatedText.householdMustHaveName));
    }
    Navigator.of(context).pop();
  }

  Future<void> _joinHousehold(
      BuildContext context, StateCubit cubit, String accessCode) async {
    final household = await FirebaseController.instance
        .joinHousehold(accessCode.trim().toUpperCase());
    if (household != null) {
      if (await addHouseholdId(household.id)) {
        cubit.addHousehold(household);
      } else {
        sendSnackBar(
            context, cubit.getTranslation(TranslatedText.cannotJoinHousehold));
      }
    } else {
      sendSnackBar(
          context, cubit.getTranslation(TranslatedText.householdDoesNotExist));
    }
    Navigator.of(context).pop();
  }
}
