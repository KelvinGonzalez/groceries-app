import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groceries_app/logic/firebase_controller.dart';
import 'package:groceries_app/logic/shared_preferences_controller.dart';
import 'package:groceries_app/logic/state_cubit.dart';
import 'package:groceries_app/logic/utils.dart';
import 'package:groceries_app/model/household.dart';
import 'package:groceries_app/model/translated_text.dart';
import 'package:groceries_app/page/household_page.dart';

class HouseholdCard extends StatelessWidget {
  final Household household;

  const HouseholdCard({super.key, required this.household});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<StateCubit>();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          FirebaseController.instance.subscribeToHousehold(household, cubit);
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const HouseholdPage()));
        },
        onLongPress: () {
          Clipboard.setData(ClipboardData(text: household.accessCode));
          sendSnackBar(
              context, cubit.getTranslation(TranslatedText.accessCodeCopied));
        },
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              decoration: BoxDecoration(
                color: cardColor(context),
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 5.0,
                    spreadRadius: 1.0,
                    color: shadowColor,
                  )
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText(
                      household.name,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const Divider(),
                    Text(
                        "${cubit.getTranslation(TranslatedText.accessCode)}: ${household.accessCode}"),
                  ],
                ),
              ),
            ),
            IconButton(
                onPressed: () {
                  removeHouseholdId(household.id);
                  cubit.removeHousehold(household.id);
                },
                icon: const Icon(
                  Icons.close,
                  size: 16,
                ))
          ],
        ),
      ),
    );
  }
}
