import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groceries_app/logic/firebase_controller.dart';
import 'package:groceries_app/logic/state_cubit.dart';
import 'package:groceries_app/model/recipe.dart';
import 'package:groceries_app/model/translated_text.dart';
import 'package:groceries_app/page/recipe_page.dart';
import 'package:groceries_app/widget/confirmation_alert.dart';
import 'package:groceries_app/widget/options_button.dart';
import 'package:groceries_app/widget/menu_dialog.dart';
import 'package:groceries_app/widget/row_card.dart';

class RecipesPage extends StatelessWidget {
  final bool isSelecting;

  const RecipesPage({super.key, this.isSelecting = false});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StateCubit, AppState>(builder: (context, state) {
      final cubit = context.read<StateCubit>();
      final recipes = state.currentHouseholdState.household?.recipes
              .where((e) => !e.isDeleted)
              .toList() ??
          [];
      return Scaffold(
        appBar: AppBar(
          title: Text(cubit.getTranslation(TranslatedText.recipes)),
          actions: const [OptionsButton()],
        ),
        body: ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      RowCard(
                        imageUrl: recipes[i].image.url,
                        aspectRatio: 5 / 3,
                        height: 80,
                        onTap: () {
                          if (isSelecting) {
                            Navigator.pop(context, recipes[i]);
                          } else {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    RecipePage(id: recipes[i].id)));
                          }
                        },
                        onLongPress: () async {
                          _showMenu(context, recipes[i]);
                        },
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: AutoSizeText(
                              recipes[i].name,
                              style: const TextStyle(fontSize: 18),
                            ),
                          )
                        ],
                      ),
                      IconButton(
                          onPressed: () async {
                            _showMenu(context, recipes[i]);
                          },
                          icon: const Icon(Icons.menu, size: 16)),
                    ],
                  ),
                )),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            final controller = TextEditingController();
            showDialog(
                context: context,
                useRootNavigator: false,
                builder: (context) => AlertDialog(
                      title: Text(
                          cubit.getTranslation(TranslatedText.createRecipe)),
                      content: TextField(
                        controller: controller,
                        onSubmitted: (value) => _submit(context, value),
                        decoration: InputDecoration(
                            hintText:
                                cubit.getTranslation(TranslatedText.enterName)),
                      ),
                      actions: [
                        IconButton(
                            onPressed: () => _submit(context, controller.text),
                            icon: const Icon(Icons.add))
                      ],
                    ));
          },
          child: const Icon(Icons.add),
        ),
      );
    });
  }

  void _showMenu(BuildContext context, Recipe recipe) {
    showDialog(
        context: context,
        useRootNavigator: false,
        builder: (context) => MenuDialog(
              name: recipe.name,
              changeName: (name) async {
                await FirebaseController.instance
                    .changeRecipeName(recipe, name);
              },
              changeImage: (image) async {
                await FirebaseController.instance
                    .swapRecipeImage(recipe, image);
              },
              delete: () async {
                final answer = await showDialog(
                        context: context,
                        useRootNavigator: false,
                        builder: (context) => ConfirmationAlert(
                            question: context
                                .read<StateCubit>()
                                .getTranslation(TranslatedText.areYouSure))) ??
                    false;
                if (answer) {
                  FirebaseController.instance.removeRecipe(recipe);
                }
                return answer;
              },
            ));
  }

  void _submit(BuildContext context, String value) {
    FirebaseController.instance.createRecipe(value.trim());
    Navigator.pop(context);
  }
}
