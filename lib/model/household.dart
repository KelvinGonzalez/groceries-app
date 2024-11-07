import 'dart:math';

import 'package:groceries_app/logic/utils.dart';
import 'package:groceries_app/model/category.dart';
import 'package:groceries_app/model/item.dart';
import 'package:groceries_app/model/recipe.dart';
import 'package:groceries_app/model/shopping_list.dart';

class Household {
  final String id;
  final String name;
  final String accessCode;
  final Map<int, Category> categories;
  final Map<int, Item> items;
  final List<Recipe> recipes;
  final List<ShoppingList> shoppingLists;

  const Household({
    required this.id,
    required this.name,
    required this.accessCode,
    required this.categories,
    required this.items,
    required this.recipes,
    required this.shoppingLists,
  });

  static String get _accessCode => String.fromCharCodes(
      List.generate(8, (_) => "A".codeUnitAt(0) + randomInt % 26));

  static Household empty(String id, String name) => Household(
        id: id,
        name: name,
        accessCode: _accessCode,
        categories: {-1: Category.root(name)},
        items: {},
        recipes: [],
        shoppingLists: [],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "accessCode": accessCode,
        "categories": categories
            .map((id, category) => MapEntry(id.toString(), category.toJson())),
        "items":
            items.map((id, item) => MapEntry(id.toString(), item.toJson())),
        "recipes": {for (var r in recipes) r.id.toString(): r.toJson()}
      };

  static Household fromJson(
      String id, Map<String, dynamic> json, List<ShoppingList> shoppingLists) {
    final categories = List<Category>.from(
        Map<String, dynamic>.from(json["categories"]).entries.map(
            (entry) => Category.fromJson(int.parse(entry.key), entry.value)))
      ..sort((a, b) => a.name.compareTo(b.name));
    final items = List<Item>.from(Map<String, dynamic>.from(json["items"])
        .entries
        .map((entry) => Item.fromJson(int.parse(entry.key), entry.value)))
      ..sort((a, b) => a.name.compareTo(b.name));
    return Household(
      id: id,
      name: json["name"],
      accessCode: json["accessCode"],
      categories: {for (var category in categories) category.id: category},
      items: {for (var item in items) item.id: item},
      recipes: List<Recipe>.from(
          Map<String, Map<String, dynamic>>.from(json["recipes"]).entries.map(
              (entry) => Recipe.fromJson(int.parse(entry.key), entry.value)))
        ..sort((a, b) => a.name.compareTo(b.name)),
      shoppingLists: shoppingLists,
    );
  }

  List<Category> getCategories(int categoryId) {
    return categories.values
        .where((e) => e.parentId == categoryId && !e.isDeleted)
        .toList();
  }

  List<Item> getItems(int categoryId) {
    return items.values.where((e) => e.parentId == categoryId).toList();
  }

  // Result is from nearest -> root
  List<Category> getItemPath(Item item, [int limitId = -1]) {
    final path = <Category>[];
    int id = item.parentId;
    while (id >= 0 && id != limitId) {
      final category = categories[id]!;
      path.add(category);
      id = category.parentId;
    }
    return path;
  }

  bool matchesName(String query, String itemName, String categoryName) {
    final queryLower = query.toLowerCase().trim();
    final itemNameLower = itemName.toLowerCase().trim();
    final categoryNameLower = categoryName.toLowerCase().trim();
    return !queryLower.split(" ").any((queryWord) => !(itemNameLower
            .split(" ")
            .any((itemNameWord) => itemNameWord.startsWith(queryWord)) ||
        categoryNameLower.split(" ").any(
            (categoryNameWord) => categoryNameWord.startsWith(queryWord))));
  }

  (List<Category>, List<Item>) search(String query, int categoryId) {
    final paths = {for (var item in items.values) item: getItemPath(item)};
    final categorySet = <Category>{};
    final itemSet = <Item>{};
    paths.forEach((item, path) {
      if (!path.any(
          (e) => e.parentId == categoryId || item.parentId == categoryId)) {
        return;
      }
      if (matchesName(query, item.name, "")) {
        itemSet.add(item);
        if (categoryId != item.parentId) {
          categorySet.add(categories[item.parentId]!);
        }
      }
      for (var category in path) {
        if (categoryId == category.id) break;
        if (matchesName(query, category.name, item.name)) {
          categorySet.add(category);
          itemSet.add(item);
          break;
        }
      }
    });
    return (categorySet.toList(), itemSet.toList());
  }

  Household updateShoppingLists(List<ShoppingList> shoppingLists) {
    return Household(
        id: id,
        name: name,
        accessCode: accessCode,
        categories: categories,
        items: items,
        recipes: recipes,
        shoppingLists: shoppingLists);
  }

  int compareItems(Item a, Item b) {
    final pathA = getItemPath(a).reversed.toList();
    final pathB = getItemPath(b).reversed.toList();
    for (var i = 0; i < min(pathA.length, pathB.length); i++) {
      if (pathA[i].id == pathB[i].id) {
        continue;
      }
      return pathA[i].name.compareTo(pathB[i].name);
    }
    if (pathA.length < pathB.length) return -1;
    if (pathA.length > pathB.length) return 1;
    return a.name.compareTo(b.name);
  }
}
