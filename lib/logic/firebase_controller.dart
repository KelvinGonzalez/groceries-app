import 'dart:async';

import 'package:groceries_app/logic/state_cubit.dart';
import 'package:groceries_app/logic/utils.dart';
import 'package:groceries_app/model/category.dart';
import 'package:groceries_app/model/household.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:groceries_app/model/item.dart';
import 'package:groceries_app/model/recipe.dart';
import 'package:groceries_app/model/shopping_list.dart';
import 'package:groceries_app/model/web_image.dart';

class FirebaseController {
  static const householdCollectionName = "Households";
  static const shoppingListsCollectionName = "Shopping Lists";
  static const maxShoppingLists = 100;

  static final _instance = FirebaseController();
  static FirebaseController get instance => _instance;
  static FirebaseFirestore get _db => FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>>? _reference;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _subscription;
  DocumentReference<Map<String, dynamic>>? _shoppingListsReference;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _shoppingListsSubscription;

  Future<List<Household>> getHouseholds(List<String> ids) async {
    final jobs =
        ids.map((id) => _db.collection(householdCollectionName).doc(id).get());
    return (await Future.wait(jobs))
        .where((household) => household.data() != null)
        .map((household) =>
            Household.fromJson(household.id, household.data()!, []))
        .toList();
  }

  void _updateShoppingListsReference(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> shoppingLists) {
    for (var list in shoppingLists) {
      if (list.data().length < maxShoppingLists) {
        _shoppingListsReference = list.reference;
        return;
      }
    }
    _shoppingListsReference = null;
  }

  List<ShoppingList> _getShoppingListConcatenation(
      Map<String, dynamic> concatenatedShoppingLists, String referenceId) {
    return concatenatedShoppingLists.entries
        .map((entries) => ShoppingList.fromJson(
            int.parse(entries.key), referenceId, entries.value))
        .toList();
  }

  void subscribeToHousehold(Household household, StateCubit cubit) {
    cancelSubscription();
    cubit.setCurrentHousehold(household);
    _reference = _db.collection(householdCollectionName).doc(household.id);
    _subscription = _reference!.snapshots().listen((household) {
      if (household.data() == null) return;
      cubit.setCurrentHousehold(Household.fromJson(
          household.id,
          household.data()!,
          cubit.state.currentHouseholdState.shoppingLists ?? []));
    });
    _shoppingListsSubscription = _reference!
        .collection(shoppingListsCollectionName)
        .snapshots()
        .listen((shoppingLists) {
      _updateShoppingListsReference(shoppingLists.docs);
      final List<ShoppingList> lists = shoppingLists.docs
          .expand((e) => _getShoppingListConcatenation(e.data(), e.id))
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      cubit.setCurrentShoppingLists(lists);
    });
  }

  void cancelSubscription() {
    _subscription?.cancel();
    _shoppingListsSubscription?.cancel();
    _subscription = null;
    _shoppingListsSubscription = null;
    _reference = null;
    _shoppingListsReference = null;
  }

  Future<Household> createHousehold(String name) async {
    final reference = _db.collection(householdCollectionName).doc();
    final household = Household.empty(reference.id, name);
    await reference.set(household.toJson());
    return household;
  }

  Future<Household?> joinHousehold(String accessCode) async {
    final docs = await _db
        .collection(householdCollectionName)
        .where("accessCode", isEqualTo: accessCode)
        .get();
    if (docs.docs.isEmpty) return null;
    final doc = docs.docs.first;
    return Household.fromJson(doc.id, doc.data(), []);
  }

  Future<void> addCategory(String name, int parentId) async {
    if (_reference == null || name.isEmpty) return;
    WebImage? image = await getValidImage(name);
    final id = randomInt;
    final category = Category(
        id: id,
        parentId: parentId,
        name: name,
        image: image ?? Category.defaultImage);
    await _reference!.update({"categories.$id": category.toJson()});
  }

  Future<Item?> addItem(String name, int parentId) async {
    if (_reference == null || name.isEmpty) return null;
    WebImage? image = await getValidImage(name);
    final id = randomInt;
    final item = Item(
        id: id,
        parentId: parentId,
        name: name,
        image: image ?? Item.defaultImage);
    await _reference!.update({"items.$id": item.toJson()});
    return item;
  }

  Future<void> removeCategory(Category category) async {
    if (_reference == null) return;
    await _reference!.update({"categories.${category.id}.isDeleted": true});
  }

  Future<void> removeItem(Item item) async {
    if (_reference == null) return;
    await _reference!.update({"items.${item.id}.isDeleted": true});
  }

  Future<void> swapCategoryImage(Category category, WebImage image) async {
    if (_reference == null) return;
    await _reference!
        .update({"categories.${category.id}.image": image.toJson()});
  }

  Future<void> swapItemImage(Item item, WebImage image) async {
    if (_reference == null) return;
    await _reference!.update({"items.${item.id}.image": image.toJson()});
  }

  Future<void> changeCategoryName(Category category, String name) async {
    if (_reference == null) return;
    if (name.trim().isEmpty) return;
    await _reference!.update({"categories.${category.id}.name": name});
  }

  Future<void> changeItemName(Item item, String name) async {
    if (_reference == null) return;
    if (name.trim().isEmpty) return;
    await _reference!.update({"items.${item.id}.name": name});
  }

  Future<void> changeCategoryParent(Category category, int parentId) async {
    if (_reference == null) return;
    await _reference!.update({"categories.${category.id}.parentId": parentId});
  }

  Future<void> changeItemParent(Item item, int parentId) async {
    if (_reference == null) return;
    await _reference!.update({"items.${item.id}.parentId": parentId});
  }

  Future<DocumentReference<Map<String, dynamic>>>
      _createShoppingListDocument() async {
    return await _reference!.collection(shoppingListsCollectionName).add({});
  }

  Future<void> createShoppingList(String name, [ShoppingList? original]) async {
    if (_reference == null || name.isEmpty) return;
    _shoppingListsReference ??= await _createShoppingListDocument();
    final id = randomInt;
    final items = original?.toJson()["items"];
    final list = {
      "name": name,
      "items": items ?? {},
      "timestamp": FieldValue.serverTimestamp(),
      "isDeleted": false,
    };
    await _shoppingListsReference!.update({
      "$id": list,
    });
  }

  DocumentReference<Map<String, dynamic>> getShoppingListReference(
      ShoppingList shoppingList) {
    if (_reference == null) throw Exception("Household reference not set");
    return _reference!
        .collection(shoppingListsCollectionName)
        .doc(shoppingList.referenceId);
  }

  Future<void> removeShoppingList(ShoppingList shoppingList) async {
    if (_reference == null) return;
    await getShoppingListReference(shoppingList).update(
      {"${shoppingList.id}.isDeleted": true},
    );
  }

  Future<void> changeShoppingListName(
      ShoppingList shoppingList, String name) async {
    if (_reference == null) return;
    if (name.trim().isEmpty) return;
    await getShoppingListReference(shoppingList)
        .update({"${shoppingList.id}.name": name});
  }

  Future<void> copyShoppingList(ShoppingList shoppingList, String name) async {
    if (_reference == null) return;
    if (name.trim().isEmpty) return;
    await createShoppingList(name, shoppingList);
  }

  Future<void> addItemToList(ShoppingList shoppingList, int itemId,
      [int count = 1]) async {
    if (_reference == null) return;
    final reference = getShoppingListReference(shoppingList);
    if (shoppingList.items.any((e) => e.itemId == itemId)) {
      await reference.update({
        "${shoppingList.id}.items.$itemId.count": FieldValue.increment(count),
      });
    } else {
      final listItem = ListItem(
          itemId: itemId, count: count, isChecked: false, isDeleted: false);
      await reference
          .update({"${shoppingList.id}.items.$itemId": listItem.toJson()});
    }
  }

  Future<void> decrementListItemCount(
      ShoppingList shoppingList, ListItem item) async {
    if (_reference == null) return;
    if (item.count <= 0) return;
    final reference = getShoppingListReference(shoppingList);
    await reference.update({
      "${shoppingList.id}.items.${item.itemId}.count": FieldValue.increment(-1)
    });
  }

  Future<void> checkListItem(ShoppingList shoppingList, ListItem item) async {
    if (_reference == null) return;
    final reference = getShoppingListReference(shoppingList);
    await reference.update(
        {"${shoppingList.id}.items.${item.itemId}.isChecked": !item.isChecked});
  }

  Future<void> addRecipeToList(ShoppingList shoppingList, Recipe recipe) async {
    if (_reference == null) return;
    for (var entry in recipe.itemCounts.entries) {
      addItemToList(shoppingList, entry.key, entry.value);
    }
  }

  Future<void> createRecipe(String name) async {
    if (_reference == null || name.isEmpty) return;
    WebImage? image = await getValidImage(name);
    final recipe = Recipe(
        id: randomInt,
        name: name,
        image: image ?? Recipe.defaultImage,
        itemCounts: {});
    await _reference!.update({"recipes.${recipe.id}": recipe.toJson()});
  }

  Future<void> removeRecipe(Recipe recipe) async {
    if (_reference == null) return;
    await _reference!.update({"recipes.${recipe.id}.isDeleted": true});
  }

  Future<void> addItemToRecipe(Recipe recipe, int itemId) async {
    if (_reference == null) return;
    final count = recipe.itemCounts[itemId];
    if (count == null || count <= 0) {
      await _reference!.update({"recipes.${recipe.id}.itemCounts.$itemId": 1});
    } else {
      await _reference!.update(
          {"recipes.${recipe.id}.itemCounts.$itemId": FieldValue.increment(1)});
    }
  }

  Future<void> decrementRecipeItemCount(Recipe recipe, int itemId) async {
    if (_reference == null) return;
    if ((recipe.itemCounts[itemId] ?? 0) <= 0) return;
    await _reference!.update(
        {"recipes.${recipe.id}.itemCounts.$itemId": FieldValue.increment(-1)});
  }

  Future<void> swapRecipeImage(Recipe recipe, WebImage image) async {
    if (_reference == null) return;
    await _reference!.update({"recipes.${recipe.id}.image": image.toJson()});
  }

  Future<void> changeRecipeName(Recipe recipe, String name) async {
    if (_reference == null) return;
    if (name.trim().isEmpty) return;
    await _reference!.update({"recipes.${recipe.id}.name": name});
  }
}
