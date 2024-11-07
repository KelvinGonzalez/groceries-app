import 'package:groceries_app/model/item.dart';
import 'package:groceries_app/model/web_image.dart';

class Recipe {
  final int id;
  final String name;
  final WebImage image;
  final Map<int, int> itemCounts; // Map of item id -> item count
  final bool isDeleted;

  static const defaultImage = WebImage(
      url:
          "https://cdn.textstudio.com/output/sample/normal/3/6/9/5/recipe-logo-913-15963.png",
      source: "https://www.textstudio.com/word-logos/recipe-15963");

  const Recipe(
      {required this.id,
      required this.name,
      required this.image,
      required this.itemCounts,
      this.isDeleted = false});

  Map<String, dynamic> toJson() => {
        "name": name,
        "image": image.toJson(),
        "itemCounts": itemCounts.map((k, v) => MapEntry(k.toString(), v)),
        "isDeleted": isDeleted,
      };

  static Recipe fromJson(int id, Map<String, dynamic> json) => Recipe(
        id: id,
        name: json["name"],
        image: WebImage.fromJson(json["image"]),
        itemCounts: Map<String, dynamic>.of(json["itemCounts"])
            .map((k, v) => MapEntry(int.parse(k), v)),
        isDeleted: json["isDeleted"],
      );

  Map<Item, int> getMappedItems(Map<int, Item> items) {
    final mappedItems = <Item, int>{};
    for (var entry in itemCounts.entries) {
      if (items[entry.key] == null || entry.value <= 0) continue;
      mappedItems[items[entry.key]!] = entry.value;
    }
    return mappedItems;
  }
}
