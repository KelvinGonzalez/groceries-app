import 'package:groceries_app/model/web_image.dart';

class Item {
  final int id;
  final int parentId;
  final String name;
  final WebImage image;
  final bool isDeleted;

  static const defaultImage = WebImage(
      url:
          "https://cdn.textstudio.com/output/sample/normal/6/1/5/5/item-logo-73-15516.png",
      source: "https://www.textstudio.com/word-logos/item-15516");

  const Item(
      {required this.id,
      required this.parentId,
      required this.name,
      this.image = defaultImage,
      this.isDeleted = false});

  Map<String, dynamic> toJson() => {
        "parentId": parentId,
        "name": name,
        "image": image.toJson(),
        "isDeleted": isDeleted,
      };

  static Item fromJson(int id, Map<String, dynamic> json) => Item(
        id: id,
        parentId: json["parentId"],
        name: json["name"],
        image: WebImage.fromJson(json["image"]),
        isDeleted: json["isDeleted"] ?? false,
      );

  @override
  bool operator ==(Object other) => other is Item && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
