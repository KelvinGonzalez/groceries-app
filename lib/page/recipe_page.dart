import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groceries_app/logic/firebase_controller.dart';
import 'package:groceries_app/logic/state_cubit.dart';
import 'package:groceries_app/model/item.dart';
import 'package:groceries_app/page/categories_page.dart';
import 'package:groceries_app/widget/dark_mode_switch.dart';
import 'package:groceries_app/widget/row_card.dart';

class RecipePage extends StatelessWidget {
  final int id;

  const RecipePage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StateCubit, AppState>(builder: (context, state) {
      final household = state.currentHouseholdState.household!;
      final recipe = household.recipes.where((e) => e.id == id).first;
      final items = recipe.getMappedItems(household.items).entries.toList()
        ..sort((a, b) => a.key.name.compareTo(b.key.name));
      return Scaffold(
        appBar: AppBar(
          title: Text(recipe.name),
          actions: const [DarkModeSwitch()],
        ),
        body: ListView.builder(
          itemCount: items.length,
          itemBuilder: (BuildContext context, int i) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: RowCard(
              imageUrl: items[i].key.image.url,
              aspectRatio: 5 / 3,
              height: 80,
              onTap: () {
                showDialog(
                    context: context,
                    useRootNavigator: false,
                    builder: (context) {
                      final screenSize = MediaQuery.of(context).size;
                      final size =
                          min(screenSize.width, screenSize.height) - 64;
                      return Center(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: size,
                                height: size,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: itemCard(
                                      context, items[i].key, false, false),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    });
              },
              children: [
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AutoSizeText(
                    items[i].key.name,
                    style: const TextStyle(fontSize: 18),
                  ),
                )),
                IconButton(
                    onPressed: () {
                      FirebaseController.instance
                          .decrementRecipeItemCount(recipe, items[i].key.id);
                    },
                    icon: const Icon(Icons.remove)),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    items[i].value.toString(),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                IconButton(
                    onPressed: () {
                      FirebaseController.instance
                          .addItemToRecipe(recipe, items[i].key.id);
                    },
                    icon: const Icon(Icons.add)),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final item = await Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    const CategoriesPage(isSelecting: true))) as Item?;
            if (item != null) {
              state.creatingItemName.clear();
              FirebaseController.instance.addItemToRecipe(recipe, item.id);
            }
          },
          child: const Icon(Icons.search),
        ),
      );
    });
  }
}
