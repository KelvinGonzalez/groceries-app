import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groceries_app/logic/firebase_controller.dart';
import 'package:groceries_app/logic/state_cubit.dart';
import 'package:groceries_app/logic/utils.dart';
import 'package:groceries_app/model/web_image.dart';
import 'package:groceries_app/page/recipe_page.dart';
import 'package:groceries_app/widget/confirmation_alert.dart';
import 'package:groceries_app/widget/dark_mode_switch.dart';
import 'package:groceries_app/widget/image_selector.dart';
import 'package:groceries_app/widget/row_card.dart';

class RecipesPage extends StatelessWidget {
  final bool isSelecting;

  const RecipesPage({super.key, this.isSelecting = false});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StateCubit, AppState>(builder: (context, state) {
      final recipes = state.currentHouseholdState.household?.recipes
              .where((e) => !e.isDeleted)
              .toList() ??
          [];
      return Scaffold(
        appBar: AppBar(
          title: const Text("Recipes"),
          actions: const [DarkModeSwitch()],
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
                          final image = await showDialog(
                            context: context,
                            useRootNavigator: false,
                            builder: (context) => FutureBuilder(
                                future: fetchImagesGoogle(recipes[i].name),
                                builder: (context, snapshot) =>
                                    ImageSelector(images: snapshot.data ?? [])),
                          ) as WebImage?;
                          if (image != null) {
                            FirebaseController.instance
                                .swapRecipeImage(recipes[i], image);
                          }
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
                            final answer = await showDialog(
                                    context: context,
                                    useRootNavigator: false,
                                    builder: (context) =>
                                        const ConfirmationAlert(
                                            question: "Are you sure?")) ??
                                false;
                            if (answer) {
                              FirebaseController.instance
                                  .removeRecipe(recipes[i]);
                            }
                          },
                          icon: const Icon(Icons.close, size: 16)),
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
                      title: const Text("Create Recipe"),
                      content: TextField(
                        controller: controller,
                        onSubmitted: (value) => _submit(context, value),
                        decoration:
                            const InputDecoration(hintText: "Enter name..."),
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

  void _submit(BuildContext context, String value) {
    FirebaseController.instance.createRecipe(value.trim());
    Navigator.pop(context);
  }
}
