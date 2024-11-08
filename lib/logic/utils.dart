import 'dart:math';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groceries_app/logic/shared_preferences_controller.dart';
import 'package:groceries_app/logic/state_cubit.dart';
import 'package:groceries_app/model/category.dart';
import 'package:groceries_app/model/item.dart';
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
const String huggingFaceKey = "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";

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

Future<(Category, double)> findBestCategoryHelper(
    Item item, List<Category> categories) async {
  if (categories.length > 10) {
    throw Exception("List is bigger than 10");
  }

  final headers = {'Authorization': 'Bearer $huggingFaceKey'};

  final data = {
    'inputs': item.name,
    'parameters': {'candidate_labels': categories.map((e) => e.name).toList()}
  };

  try {
    final response = await http.post(
      Uri.parse(
          'https://api-inference.huggingface.co/models/facebook/bart-large-mnli'),
      headers: headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return (
        categories.where((e) => e.name == result['labels'][0]).first,
        result['scores'][0] as double
      );
    } else {
      throw Exception('Error: ${response.statusCode}, ${response.body}');
    }
  } catch (e) {
    throw Exception('Error: $e');
  }
}

Future<Category> findBestCategory(Item item, List<Category> categories) async {
  final jobs = <Future<(Category, double)>>[];
  for (var i = 0; i < categories.length; i += 10) {
    jobs.add(findBestCategoryHelper(
        item, categories.sublist(i, min(i + 10, categories.length))));
  }
  final results = await Future.wait(jobs);
  return results.reduce((a, b) => a.$2 >= b.$2 ? a : b).$1;
}
