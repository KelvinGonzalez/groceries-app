import 'package:flutter/material.dart';
import 'package:groceries_app/logic/utils.dart';
import 'package:groceries_app/model/web_image.dart';
import 'package:groceries_app/page/category_select_page.dart';
import 'package:groceries_app/widget/image_selector.dart';

class MenuDialog extends StatelessWidget {
  final String? name;
  final int? ignoredId;

  final Future<void> Function(String)? changeName;
  final Future<void> Function(WebImage)? changeImage;
  final Future<void> Function(int)? changeParent;
  final Future<void> Function(String)? copy;
  final Future<bool> Function()? delete;

  const MenuDialog(
      {super.key,
      this.name,
      this.ignoredId,
      this.changeName,
      this.changeImage,
      this.changeParent,
      this.copy,
      this.delete});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Menu"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (name != null && changeName != null)
            TextButton(
                onPressed: () async {
                  final controller = TextEditingController(text: name!);
                  final newName = await showDialog(
                      context: context,
                      useRootNavigator: false,
                      builder: (context) => AlertDialog(
                            title: const Text("Change Name"),
                            content: TextField(
                              controller: controller,
                              decoration: const InputDecoration(
                                hintText: "Enter new name...",
                              ),
                              onSubmitted: (value) =>
                                  Navigator.pop(context, value.trim()),
                            ),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Cancel")),
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(
                                        context, controller.text.trim());
                                  },
                                  child: const Text("Submit"))
                            ],
                          )) as String?;
                  if (newName != null) {
                    await changeName!(newName);
                  }
                },
                child: const Text("Change Name")),
          if (name != null && changeImage != null)
            TextButton(
                onPressed: () async {
                  final images = await fetchImagesGoogle(name!);
                  final image = await showDialog(
                          context: context,
                          useRootNavigator: false,
                          builder: (context) => ImageSelector(images: images))
                      as WebImage?;
                  if (image != null) {
                    await changeImage!(image);
                  }
                },
                child: const Text("Change Image")),
          if (changeParent != null)
            TextButton(
                onPressed: () async {
                  final newParentId = await Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) =>
                              CategorySelectPage(ignoreId: ignoredId))) as int?;
                  if (newParentId != null) {
                    await changeParent!(newParentId);
                  }
                },
                child: const Text("Change Location")),
          if (name != null && copy != null)
            TextButton(
              onPressed: () async {
                final controller = TextEditingController(text: name!);
                final newName = await showDialog(
                    context: context,
                    useRootNavigator: false,
                    builder: (context) => AlertDialog(
                          title: const Text("Copying"),
                          content: TextField(
                            controller: controller,
                            decoration: const InputDecoration(
                              hintText: "Enter copy name...",
                            ),
                            onSubmitted: (value) =>
                                Navigator.pop(context, value.trim()),
                          ),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("Cancel")),
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(
                                      context, controller.text.trim());
                                },
                                child: const Text("Submit"))
                          ],
                        )) as String?;
                if (newName != null) {
                  await copy!(newName);
                }
              },
              child: const Text("Copy"),
            ),
          if (delete != null)
            TextButton(
                onPressed: () async {
                  if (await delete!()) {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text("Delete")),
        ],
      ),
    );
  }
}
