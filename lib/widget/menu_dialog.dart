import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groceries_app/logic/state_cubit.dart';
import 'package:groceries_app/logic/utils.dart';
import 'package:groceries_app/model/translated_text.dart';
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
    final cubit = context.read<StateCubit>();
    return AlertDialog(
      title: Text(cubit.getTranslation(TranslatedText.menu)),
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
                            title: Text(cubit
                                .getTranslation(TranslatedText.changeName)),
                            content: TextField(
                              controller: controller,
                              decoration: InputDecoration(
                                hintText: cubit.getTranslation(
                                    TranslatedText.enterNewName),
                              ),
                              onSubmitted: (value) =>
                                  Navigator.pop(context, value.trim()),
                            ),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(cubit
                                      .getTranslation(TranslatedText.cancel))),
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(
                                        context, controller.text.trim());
                                  },
                                  child: Text(cubit
                                      .getTranslation(TranslatedText.submit)))
                            ],
                          )) as String?;
                  if (newName != null) {
                    await changeName!(newName);
                  }
                },
                child: Text(cubit.getTranslation(TranslatedText.changeName))),
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
                child: Text(cubit.getTranslation(TranslatedText.changeImage))),
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
                child:
                    Text(cubit.getTranslation(TranslatedText.changeLocation))),
          if (name != null && copy != null)
            TextButton(
              onPressed: () async {
                final controller = TextEditingController(text: name!);
                final newName = await showDialog(
                    context: context,
                    useRootNavigator: false,
                    builder: (context) => AlertDialog(
                          title: Text(
                              cubit.getTranslation(TranslatedText.copying)),
                          content: TextField(
                            controller: controller,
                            decoration: InputDecoration(
                              hintText: cubit
                                  .getTranslation(TranslatedText.enterCopyName),
                            ),
                            onSubmitted: (value) =>
                                Navigator.pop(context, value.trim()),
                          ),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(cubit
                                    .getTranslation(TranslatedText.cancel))),
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(
                                      context, controller.text.trim());
                                },
                                child: Text(cubit
                                    .getTranslation(TranslatedText.submit)))
                          ],
                        )) as String?;
                if (newName != null) {
                  await copy!(newName);
                }
              },
              child: Text(cubit.getTranslation(TranslatedText.copy)),
            ),
          if (delete != null)
            TextButton(
                onPressed: () async {
                  if (await delete!()) {
                    Navigator.of(context).pop();
                  }
                },
                child: Text(cubit.getTranslation(TranslatedText.delete))),
        ],
      ),
    );
  }
}
