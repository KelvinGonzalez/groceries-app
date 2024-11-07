import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groceries_app/logic/firebase_controller.dart';
import 'package:groceries_app/logic/state_cubit.dart';
import 'package:groceries_app/model/item.dart';
import 'package:groceries_app/model/recipe.dart';
import 'package:groceries_app/model/shopping_list.dart';
import 'package:groceries_app/page/categories_page.dart';
import 'package:groceries_app/page/recipe_page.dart';
import 'package:groceries_app/page/recipes_page.dart';
import 'package:groceries_app/widget/dark_mode_switch.dart';
import 'package:groceries_app/widget/row_card.dart';

class ListPage extends StatelessWidget {
  final int id;

  const ListPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StateCubit, AppState>(builder: (context, state) {
      final household = state.currentHouseholdState.household!;
      final shoppingList = state.currentHouseholdState.shoppingLists!
          .where((e) => e.id == id)
          .first;
      final items = shoppingList.getMappedItems(household.items)
        ..sort((a, b) => household.compareItems(a.$1, b.$1));
      final uncheckedItems = items.where((e) => !e.$2.isChecked).toList();
      final checkedItems = items.where((e) => e.$2.isChecked).toList();
      return Scaffold(
        appBar: AppBar(
          title: Text(shoppingList.name),
          actions: const [DarkModeSwitch()],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                  itemCount: items.length +
                      (items.length == uncheckedItems.length ? 0 : 1),
                  itemBuilder: (context, i) {
                    if (i < uncheckedItems.length) {
                      return _rowItem(context, shoppingList,
                          uncheckedItems[i].$1, uncheckedItems[i].$2);
                    } else if (i == uncheckedItems.length) {
                      return const Divider();
                    } else {
                      int index = i - uncheckedItems.length - 1;
                      return _rowItem(context, shoppingList,
                          checkedItems[index].$1, checkedItems[index].$2);
                    }
                  }),
            ),
            const SizedBox(height: 88)
          ],
        ),
        floatingActionButton: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              heroTag: "btn1",
              onPressed: () async {
                final recipe = await Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) =>
                            const RecipesPage(isSelecting: true))) as Recipe?;
                if (recipe != null) {
                  FirebaseController.instance
                      .addRecipeToList(shoppingList, recipe);
                }
              },
              child: const Icon(Icons.menu_book),
            ),
            const SizedBox(width: 12),
            FloatingActionButton(
              heroTag: "btn2",
              onPressed: () async {
                final item = await Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        const CategoriesPage(isSelecting: true))) as Item?;
                if (item != null) {
                  state.creatingItemName.clear();
                  FirebaseController.instance
                      .addItemToList(shoppingList, item.id);
                }
              },
              child: const Icon(Icons.search),
            ),
          ],
        ),
      );
    });
  }

  Widget _rowItem(BuildContext context, ShoppingList shoppingList, Item item,
      ListItem listItem) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        foregroundDecoration: BoxDecoration(
          color: Colors.black
              .withOpacity(listItem.isChecked ? 0.4 : 0), // Dark overlay effect
          borderRadius: BorderRadius.circular(10),
        ),
        child: RowCard(
          imageUrl: item.image.url,
          aspectRatio: 5 / 3,
          height: 80,
          onTap: () {
            showDialog(
                context: context,
                useRootNavigator: false,
                builder: (context) {
                  final screenSize = MediaQuery.of(context).size;
                  final size = min(screenSize.width, screenSize.height) - 64;
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
                              child: itemCard(context, item, false, false),
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
                  item.name,
                  style: TextStyle(
                      fontSize: 18,
                      decoration: listItem.isChecked
                          ? TextDecoration.lineThrough
                          : TextDecoration.none),
                ),
              ),
            ),
            IconButton(
                onPressed: () {
                  FirebaseController.instance
                      .decrementListItemCount(shoppingList, listItem);
                },
                icon: const Icon(Icons.remove)),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                listItem.count.toString(),
                style: const TextStyle(fontSize: 16),
              ),
            ),
            IconButton(
                onPressed: () {
                  FirebaseController.instance
                      .addItemToList(shoppingList, listItem.itemId);
                },
                icon: const Icon(Icons.add)),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Checkbox(
                  value: listItem.isChecked,
                  onChanged: (_) {
                    FirebaseController.instance
                        .checkListItem(shoppingList, listItem);
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
