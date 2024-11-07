import 'dart:convert';

class WebImage {
  final String url;
  final String source;

  const WebImage({required this.url, required this.source});

  Map<String, dynamic> toJson() => {
        "url": url,
        "source": source,
      };

  String serialize() => jsonEncode(toJson());

  static WebImage fromJson(Map<String, dynamic> json) =>
      WebImage(url: json["url"], source: json["source"]);

  static WebImage deserialize(String jsonString) =>
      fromJson(jsonDecode(jsonString));
}
