import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groceries_app/logic/firebase_controller.dart';
import 'package:groceries_app/logic/state_cubit.dart';
import 'package:groceries_app/logic/utils.dart';
import 'package:groceries_app/model/translated_text.dart';
import 'package:groceries_app/page/categories_page.dart';
import 'package:groceries_app/page/lists_page.dart';
import 'package:groceries_app/page/recipes_page.dart';
import 'package:groceries_app/widget/options_button.dart';

class HouseholdPage extends StatelessWidget {
  const HouseholdPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (popped, value) {
        FirebaseController.instance.cancelSubscription();
      },
      child: BlocBuilder<StateCubit, AppState>(builder: (context, state) {
        if (state.currentHouseholdState.household == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final cubit = context.read<StateCubit>();
        final household = state.currentHouseholdState.household!;
        return Scaffold(
          appBar: AppBar(
            title: Text(household.name),
            actions: const [OptionsButton()],
          ),
          body: Column(
            children: [
              Expanded(
                  child: _cardBase(context,
                      title: cubit.getTranslation(TranslatedText.shoppingLists),
                      child: Container(),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const ListsPage())))),
              Expanded(
                  child: _cardBase(context,
                      title: cubit.getTranslation(TranslatedText.items),
                      child: Container(),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const CategoriesPage())))),
              Expanded(
                  child: _cardBase(context,
                      title: cubit.getTranslation(TranslatedText.recipes),
                      child: Container(),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const RecipesPage())))),
            ],
          ),
        );
      }),
    );
  }

  Widget _cardBase(BuildContext context,
      {required String title, required Widget child, void Function()? onTap}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
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
                Text(
                  title,
                  style: const TextStyle(fontSize: 20),
                ),
                const Divider(),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
