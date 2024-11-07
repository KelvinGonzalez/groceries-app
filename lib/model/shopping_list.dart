import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:groceries_app/model/item.dart';

class ListItem {
  final int itemId;
  final int count;
  final bool isChecked;
  final bool isDeleted;

  const ListItem(
      {required this.itemId,
      required this.count,
      required this.isChecked,
      required this.isDeleted});

  Map<String, dynamic> toJson() => {
        "count": count,
        "isChecked": isChecked,
      };

  static ListItem fromJson(int id, Map<String, dynamic> json) => ListItem(
        itemId: id,
        count: json["count"] >= 0 ? json["count"] : 0,
        isChecked: json["isChecked"],
        isDeleted: json["count"] <= 0,
      );
}

class ShoppingList {
  final int id;
  final String referenceId;
  final String name;
  final List<ListItem> items;
  final Timestamp timestamp;
  final bool isDeleted;

  const ShoppingList(
      {required this.id,
      required this.referenceId,
      required this.name,
      required this.items,
      required this.timestamp,
      this.isDeleted = false});

  Map<String, dynamic> toJson() => {
        "name": name,
        "items": {for (var item in items) item.itemId: item.toJson()},
        "timestamp": timestamp,
        "isDeleted": isDeleted,
      };

  static ShoppingList fromJson(
          int id, String referenceId, Map<String, dynamic> json) =>
      ShoppingList(
        id: id,
        referenceId: referenceId,
        name: json["name"],
        items: List<ListItem>.from(Map<String, dynamic>.from(json["items"])
            .entries
            .map(
                (entry) => ListItem.fromJson(int.parse(entry.key), entry.value))
            .where((e) => !e.isDeleted)),
        timestamp: json["timestamp"] ?? Timestamp.now(),
        isDeleted: json["isDeleted"],
      );

  List<(Item, ListItem)> getMappedItems(Map<int, Item> items) => this
      .items
      .expand((e) => items[e.itemId] == null
          ? <(Item, ListItem)>[]
          : [(items[e.itemId]!, e)])
      .toList();
}
