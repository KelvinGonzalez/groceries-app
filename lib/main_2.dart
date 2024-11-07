// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:html/parser.dart' show parse;
//
// void main() {
//   runApp(const MaterialApp(home: ImageFetcher()));
// }
//
// class ImageFetcher extends StatefulWidget {
//   const ImageFetcher({super.key});
//
//   @override
//   ImageFetcherState createState() => ImageFetcherState();
// }
//
// class ImageFetcherState extends State<ImageFetcher> {
//   List<String> imageUrls = [];
//
//   Future<String> fetchHtml(String url) async {
//     final response = await http.get(Uri.parse(url));
//     if (response.statusCode == 200) {
//       return response.body;
//     } else {
//       throw Exception('Failed to fetch HTML: ${response.statusCode}');
//     }
//   }
//
//   Future<List<String>> extractImageUrls(String html) async {
//     final document = parse(html);
//     final imageElements = document.querySelectorAll('img');
//     final imageUrls =
//         imageElements.map((img) => img.attributes['src']!).toList();
//     return imageUrls;
//   }
//
//   Future<void> fetchImages() async {
//     final html = await fetchHtml(
//         'https://www.google.com/search?q=dog&udm=2'); // Replace with your desired URL
//     final urls = await extractImageUrls(html);
//     setState(() {
//       imageUrls = urls;
//     });
//   }
//
//   Widget buildImage(String imageUrl) {
//     return Image.network(imageUrl);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Image Fetcher'),
//       ),
//       body: FutureBuilder(
//         future: fetchImages(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             return ListView.builder(
//               itemCount: imageUrls.length,
//               itemBuilder: (context, index) {
//                 return buildImage(imageUrls[index]);
//               },
//             );
//           } else {
//             return const Center(child: CircularProgressIndicator());
//           }
//         },
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:html/parser.dart' as parser;
//
// class DuckDuckGoImageSearchApp extends StatefulWidget {
//   const DuckDuckGoImageSearchApp({super.key});
//
//   @override
//   _DuckDuckGoImageSearchAppState createState() =>
//       _DuckDuckGoImageSearchAppState();
// }
//
// class _DuckDuckGoImageSearchAppState extends State<DuckDuckGoImageSearchApp> {
//   List<String> imageUrls = [];
//
//   Future<void> fetchImages(String query) async {
//     final url = Uri.parse(
//         'https://duckduckgo.com/?q=${Uri.encodeComponent(query)}&iax=images&ia=images');
//
//     try {
//       final response = await http.get(url, headers: {
//         "Access-Control-Allow-Origin": "*",
//         "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
//         "Access-Control-Allow-Headers": "Content-Type"
//       });
//       if (response.statusCode == 200) {
//         final document = parser.parse(response.body);
//         final elements = document.getElementsByClassName('tile--img__img');
//         setState(() {
//           imageUrls = elements
//               .map((element) => element.attributes['src'] ?? '')
//               .toList();
//         });
//       } else {
//         throw Exception('Failed to load images');
//       }
//     } catch (e) {
//       print("Error fetching images: $e");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('DuckDuckGo Image Search')),
//       body: Column(
//         children: [
//           TextField(
//             onSubmitted: (value) => fetchImages(value),
//             decoration: InputDecoration(
//               labelText: 'Enter search term',
//               border: OutlineInputBorder(),
//             ),
//           ),
//           Expanded(
//             child: GridView.builder(
//               gridDelegate:
//                   SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
//               itemCount: imageUrls.length,
//               itemBuilder: (context, index) {
//                 return imageUrls[index].isNotEmpty
//                     ? Image.network(imageUrls[index], fit: BoxFit.cover)
//                     : Container();
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// void main() => runApp(MaterialApp(home: DuckDuckGoImageSearchApp()));

// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
//
// class DuckDuckGoImageSearchWebView extends StatefulWidget {
//   @override
//   _DuckDuckGoImageSearchWebViewState createState() =>
//       _DuckDuckGoImageSearchWebViewState();
// }
//
// class _DuckDuckGoImageSearchWebViewState
//     extends State<DuckDuckGoImageSearchWebView> {
//   final TextEditingController _controller = TextEditingController();
//
//   WebViewController? _webViewController;
//
//   void _searchImages() {
//     final query = Uri.encodeComponent(_controller.text);
//     final url = 'https://duckduckgo.com/?q=$query&iax=images&ia=images';
//     _webViewController?.loadHtmlString(url);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: TextField(
//           controller: _controller,
//           decoration: InputDecoration(
//             hintText: 'Enter search term',
//           ),
//           onSubmitted: (_) => _searchImages(),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.search),
//             onPressed: _searchImages,
//           ),
//         ],
//       ),
//       body: WebView(
//         initialUrl: 'https://duckduckgo.com/?iax=images&ia=images',
//         onWebViewCreated: (controller) {
//           _webViewController = controller;
//         },
//         javascriptMode: JavascriptMode.unrestricted,
//       ),
//     );
//   }
// }
//
// void main() => runApp(MaterialApp(home: DuckDuckGoImageSearchWebView()));

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// class OpenverseImageSearchApp extends StatefulWidget {
//   @override
//   _OpenverseImageSearchAppState createState() =>
//       _OpenverseImageSearchAppState();
// }
//
// class _OpenverseImageSearchAppState extends State<OpenverseImageSearchApp> {
//   List<String> _imageUrls = [];
//   final TextEditingController _controller = TextEditingController();
//
//   Future<void> fetchImages(String query) async {
//     final url = 'https://api.openverse.org/v1/images/?q=$query';
//     final response = await http.get(Uri.parse(url));
//
//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       setState(() {
//         _imageUrls = (data['results'] as List)
//             .map((item) => item['url']
//                 as String) // Adjust the key based on the API response structure
//             .toList();
//       });
//     } else {
//       throw Exception('Failed to load images');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: TextField(
//           controller: _controller,
//           onSubmitted: (value) {
//             fetchImages(value);
//             _controller.clear();
//           },
//           decoration: InputDecoration(labelText: 'Search images'),
//         ),
//       ),
//       body: _imageUrls.isNotEmpty
//           ? GridView.builder(
//               gridDelegate:
//                   SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
//               itemCount: _imageUrls.length,
//               itemBuilder: (context, index) {
//                 return Image.network(_imageUrls[index]);
//               },
//             )
//           : Center(child: Text('No images found')),
//     );
//   }
// }
//
// void main() => runApp(MaterialApp(home: OpenverseImageSearchApp()));

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// class DuckDuckGoImageSearchApp extends StatefulWidget {
//   @override
//   _DuckDuckGoImageSearchAppState createState() =>
//       _DuckDuckGoImageSearchAppState();
// }
//
// class _DuckDuckGoImageSearchAppState extends State<DuckDuckGoImageSearchApp> {
//   List<String> _imageUrls = [];
//   final TextEditingController _controller = TextEditingController();
//
//   Future<void> fetchImages(String query) async {
//     final url =
//         'https://api.duckduckgo.com/?q=$query&format=json&no_redirect=1&iax=images&ia=images';
//     final response = await http.get(Uri.parse(url));
//
//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       setState(() {
//         // Update this line based on the actual structure of the DuckDuckGo response
//         _imageUrls = (data['RelatedTopics'] as List)
//             .where((item) => item['Icon'] != null) // Ensure there's an icon
//             .map((item) =>
//                 "https://duckduckgo.com${item['Icon']['URL']}") // Adjust if the key is different
//             .toList();
//         print(_imageUrls);
//       });
//     } else {
//       throw Exception('Failed to load images');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: TextField(
//           controller: _controller,
//           onSubmitted: (value) {
//             fetchImages(value);
//             _controller.clear();
//           },
//           decoration: InputDecoration(labelText: 'Search images'),
//         ),
//       ),
//       body: _imageUrls.isNotEmpty
//           ? GridView.builder(
//               gridDelegate:
//                   SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1),
//               itemCount: _imageUrls.length,
//               itemBuilder: (context, index) {
//                 return Image.network(_imageUrls[index]);
//               },
//             )
//           : Center(child: Text('No images found')),
//     );
//   }
// }
//
// void main() => runApp(MaterialApp(home: DuckDuckGoImageSearchApp()));
