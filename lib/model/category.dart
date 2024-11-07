import 'package:groceries_app/model/web_image.dart';

class Category {
  final int id;
  final int parentId;
  final String name;
  final WebImage image;
  final bool isDeleted;

  static const defaultImage = WebImage(
      url:
          "https://cdn.textstudio.com/output/sample/normal/8/9/7/4/category-logo-73-14798.png",
      source: "https://www.textstudio.com/word-logos/category-14798");

  const Category({
    required this.id,
    required this.parentId,
    required this.name,
    this.image = defaultImage,
    this.isDeleted = false,
  });

  static Category root(String name) => Category(
        id: -1,
        parentId: -2,
        name: name,
        image: defaultImage,
      );

  Map<String, dynamic> toJson() => {
        "parentId": parentId,
        "name": name,
        "image": image.toJson(),
        "isDeleted": isDeleted,
      };

  static Category fromJson(int id, Map<String, dynamic> json) => Category(
        id: id,
        parentId: json["parentId"],
        name: json["name"],
        image: WebImage.fromJson(json["image"]),
        isDeleted: json["isDeleted"],
      );

  @override
  bool operator ==(Object other) => other is Category && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
