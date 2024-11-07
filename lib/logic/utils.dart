import 'dart:math';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groceries_app/logic/shared_preferences_controller.dart';
import 'package:groceries_app/logic/state_cubit.dart';
import 'package:groceries_app/model/web_image.dart';
import 'package:http/http.dart' as http;

const shadowColor = Colors.black45;

Color cardColor(BuildContext context) =>
    context.read<StateCubit>().state.isDarkMode
        ? const Color.fromRGBO(35, 35, 35, 1)
        : Colors.white;

void sendSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

int get randomInt => Random().nextInt(0xFFFFFFFF);

const String apiKey = "AIzaSyBB9qaPZ-wpfua2dssGGQ6C9X7GydfqDrQ";
const String cxKey = "800fa5508bfa744e5";

Future<List<WebImage>> fetchImagesGoogle(String query) async {
  final trimmed = query.trim().toLowerCase();
  final cachedImages = await getCachedImages(trimmed);
  if (cachedImages != null) {
    return cachedImages;
  }

  final url =
      "https://www.googleapis.com/customsearch/v1?q=$query&cx=$cxKey&searchType=image&key=$apiKey";
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final rawImages = List<WebImage>.from(data["items"].map((item) =>
        WebImage(url: item["link"], source: item["image"]["contextLink"])));
    await setCachedImages(trimmed, rawImages);
    final isAllowedJobs = rawImages.map((e) => isImageAllowed(e.url));
    Future.wait(isAllowedJobs).then((isAllowed) async {
      final images = <WebImage>[];
      for (var i = 0; i < rawImages.length; i++) {
        if (isAllowed[i]) images.add(rawImages[i]);
      }
      await setCachedImages(trimmed, images);
    });
    return rawImages;
  } else {
    throw Exception('Failed to load images');
  }
}

Future<bool> isImageAllowed(String imageUrl) async {
  try {
    final response = await http.head(Uri.parse(imageUrl));
    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}

Future<WebImage?> getValidImage(String query) async {
  WebImage? image;
  for (var i in await fetchImagesGoogle(query)) {
    if (await isImageAllowed(i.url)) {
      image = i;
      break;
    }
  }
  return image;
}

Future<List<WebImage>> fetchImagesPixabay(String query) async {
  final url =
      "https://pixabay.com/api/?key=46900453-6ae2d070113b5d0d3976ed348&q=$query";
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return List<WebImage>.from(data["hits"].map(
        (hit) => WebImage(url: hit["webformatURL"], source: hit["pageURL"])));
  } else {
    throw Exception('Failed to load images');
  }
}

Future<List<WebImage>> fetchImagesOpenverse(String query) async {
  final url = 'https://api.openverse.org/v1/images/?q=$query';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return List<WebImage>.from(data['results'].map((item) =>
        WebImage(url: item["url"], source: item["foreign_landing_url"])));
  } else {
    throw Exception('Failed to load images');
  }
}
