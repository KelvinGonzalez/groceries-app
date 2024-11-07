import 'package:groceries_app/logic/firebase_controller.dart';
import 'package:groceries_app/model/web_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

const darkModeName = "darkMode";

Future<bool> addHouseholdId(String id) async {
  final prefs = await SharedPreferences.getInstance();
  final ids =
      prefs.getStringList(FirebaseController.householdCollectionName) ?? [];
  if (ids.contains(id)) return false;
  prefs.setStringList(FirebaseController.householdCollectionName, [...ids, id]);
  return true;
}

Future<void> removeHouseholdId(String id) async {
  final prefs = await SharedPreferences.getInstance();
  final ids =
      prefs.getStringList(FirebaseController.householdCollectionName) ?? [];
  if (!ids.contains(id)) return;
  prefs.setStringList(FirebaseController.householdCollectionName,
      ids.where((e) => e != id).toList());
}

Future<bool> getDarkMode() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(darkModeName) ?? false;
}

Future<void> setDarkMode(bool value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(darkModeName, value);
}

Future<List<WebImage>?> getCachedImages(String query) async {
  final prefs = await SharedPreferences.getInstance();
  final cache = prefs.getStringList("search_$query");
  return cache?.map((e) => WebImage.deserialize(e)).toList();
}

Future<void> setCachedImages(String query, List<WebImage> images) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList(
      "search_$query", images.map((e) => e.serialize()).toList());
}