import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groceries_app/logic/shared_preferences_controller.dart';
import 'package:groceries_app/model/category.dart';
import 'package:groceries_app/model/household.dart';
import 'package:groceries_app/model/item.dart';
import 'package:groceries_app/model/shopping_list.dart';
import 'package:groceries_app/model/translated_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_controller.dart';

class CurrentHouseholdState {
  final Household? household;
  final List<ShoppingList>? shoppingLists;

  const CurrentHouseholdState({this.household, this.shoppingLists});
}

class AppState {
  final bool isDarkMode;
  final CurrentHouseholdState currentHouseholdState;
  final List<Household> households;
  final bool creatingItem;
  final TextEditingController creatingItemName;
  final (List<Category>, List<Item>) searchResult;
  final Language language;

  const AppState(
      {required this.isDarkMode,
      required this.currentHouseholdState,
      required this.households,
      required this.creatingItem,
      required this.creatingItemName,
      required this.searchResult,
      required this.language});

  static AppState get initialState => AppState(
        isDarkMode: false,
        currentHouseholdState: const CurrentHouseholdState(),
        households: const [],
        creatingItem: true,
        creatingItemName: TextEditingController(),
        searchResult: ([], []),
        language: Language.english,
      );
}

class StateCubit extends Cubit<AppState> {
  StateCubit() : super(AppState.initialState);

  Future<void> _initHouseholds() async {
    final prefs = await SharedPreferences.getInstance();
    final ids =
        prefs.getStringList(FirebaseController.householdCollectionName) ?? [];
    final households = await FirebaseController.instance.getHouseholds(ids);
    setHouseholds(households);
  }

  Future<void> init() async {
    setDarkMode(await getDarkMode());
    setLanguage(await getLanguage());
    await _initHouseholds();
  }

  void update({
    bool? isDarkMode,
    CurrentHouseholdState? currentHouseholdState,
    List<Household>? households,
    bool? creatingItem,
    TextEditingController? creatingItemName,
    (List<Category>, List<Item>)? searchResult,
    Language? language,
  }) {
    emit(AppState(
      isDarkMode: isDarkMode ?? state.isDarkMode,
      currentHouseholdState:
          currentHouseholdState ?? state.currentHouseholdState,
      households: households ?? state.households,
      creatingItem: creatingItem ?? state.creatingItem,
      creatingItemName: creatingItemName ?? state.creatingItemName,
      searchResult: searchResult ?? state.searchResult,
      language: language ?? state.language,
    ));
  }

  void setDarkMode(bool isDarkMode) {
    update(isDarkMode: isDarkMode);
  }

  void setCurrentHousehold(Household household) {
    update(
        currentHouseholdState: CurrentHouseholdState(
            household: household,
            shoppingLists: state.currentHouseholdState.shoppingLists));
  }

  void setCurrentShoppingLists(List<ShoppingList> shoppingLists) {
    update(
        currentHouseholdState: CurrentHouseholdState(
            household: state.currentHouseholdState.household
                ?.updateShoppingLists(shoppingLists),
            shoppingLists: shoppingLists));
  }

  void setHouseholds(List<Household> households) {
    update(households: households);
  }

  void addHousehold(Household household) {
    setHouseholds([...state.households, household]);
  }

  void removeHousehold(String id) {
    setHouseholds(state.households.where((e) => e.id != id).toList());
  }

  void setSearchResult((List<Category>, List<Item>) searchResult) {
    update(searchResult: searchResult);
  }

  void resetSearchResult() {
    update(searchResult: ([], []));
  }

  List<Category> getUpdatedSearchCategories() {
    if (state.currentHouseholdState.household == null) {
      throw Exception("Household is null");
    }
    return state.searchResult.$1.expand((e) {
      final category = state.currentHouseholdState.household!.categories[e.id];
      return category == null ? <Category>[] : [category];
    }).toList();
  }

  List<Item> getUpdatedSearchItems() {
    if (state.currentHouseholdState.household == null) {
      throw Exception("Household is null");
    }
    return state.searchResult.$2.expand((e) {
      final item = state.currentHouseholdState.household!.items[e.id];
      return item == null ? <Item>[] : [item];
    }).toList();
  }

  void setLanguage(Language language) {
    update(language: language);
  }

  String getTranslation(TranslatedText text) => text.get(state.language);
}
