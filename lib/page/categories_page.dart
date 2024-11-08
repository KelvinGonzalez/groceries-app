import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groceries_app/logic/firebase_controller.dart';
import 'package:groceries_app/logic/state_cubit.dart';
import 'package:groceries_app/logic/utils.dart';
import 'package:groceries_app/model/category.dart';
import 'package:groceries_app/model/item.dart';
import 'package:groceries_app/model/translated_text.dart';
import 'package:groceries_app/widget/confirmation_alert.dart';
import 'package:groceries_app/widget/options_button.dart';
import 'package:groceries_app/widget/fade_in_network_image.dart';
import 'package:groceries_app/widget/menu_dialog.dart';
import 'package:groceries_app/widget/row_card.dart';

class CategoriesPage extends StatefulWidget {
  static const _itemCardWidth = 200.0;

  final bool isSelecting;

  const CategoriesPage({super.key, this.isSelecting = false});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  late StateCubit _cubit;
  int _currentId = -1;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<StateCubit>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StateCubit, AppState>(
      builder: (context, state) {
        final household = state.currentHouseholdState.household!;
        final searching = state.creatingItemName.text.trim().isNotEmpty;
        final categories = searching && state.searchResult.$2.isNotEmpty
            ? _cubit.getUpdatedSearchCategories()
            : household.getCategories(_currentId);
        final items = searching
            ? _cubit.getUpdatedSearchItems()
            : household.getItems(_currentId);
        return PopScope(
            canPop: false,
            onPopInvokedWithResult: (popped, result) {
              if (popped) return;
              final category = household.categories[_currentId]!;
              if (category.id == -1) {
                Navigator.pop(context);
                return;
              }
              setState(() {
                _currentId = category.parentId;
                _search();
              });
            },
            child: Scaffold(
              appBar: AppBar(
                title: Row(
                  children: [
                    Text(household.categories[_currentId]!.name),
                    if (searching)
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Icon(Icons.search),
                      ),
                  ],
                ),
                actions: const [OptionsButton()],
              ),
              body: Column(
                children: [
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, i) {
                              return _categoryRow(
                                  context, setState, categories[i]);
                            },
                            childCount: categories.length,
                          ),
                        ),
                        SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                            (context, i) {
                              return itemCard(context, items[i], true,
                                  widget.isSelecting, _setParent);
                            },
                            childCount: items.length,
                          ),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: max(
                                    (MediaQuery.of(context).size.width /
                                        CategoriesPage._itemCardWidth),
                                    1)
                                .round(),
                            childAspectRatio: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 0),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                      child: TextField(
                                    controller: state.creatingItemName,
                                    onChanged: (value) => _search(),
                                    onSubmitted: (value) {
                                      if (widget.isSelecting) {
                                        final item =
                                            state.searchResult.$2.firstOrNull;
                                        if (item != null) {
                                          Navigator.of(context).pop(item);
                                          return;
                                        }
                                      }
                                      _onSubmitted(state);
                                    },
                                    decoration: InputDecoration(
                                      hintText: _cubit.getTranslation(state
                                              .creatingItem
                                          ? TranslatedText.enterItemName
                                          : TranslatedText.enterCategoryName),
                                      suffixIcon: IconButton(
                                        icon: const Icon(Icons.clear, size: 16),
                                        onPressed: () {
                                          state.creatingItemName.clear();
                                          _cubit.resetSearchResult();
                                        },
                                      ),
                                    ),
                                  )),
                                  const SizedBox(width: 8.0)
                                ],
                              ),
                              Row(
                                children: [
                                  Radio(
                                      value: true,
                                      groupValue: state.creatingItem,
                                      onChanged: (value) {
                                        _cubit.update(creatingItem: value);
                                      }),
                                  Text(_cubit
                                      .getTranslation(TranslatedText.item)),
                                  const SizedBox(width: 16),
                                  Radio(
                                      value: false,
                                      groupValue: state.creatingItem,
                                      onChanged: (value) {
                                        _cubit.update(creatingItem: value);
                                      }),
                                  Text(_cubit
                                      .getTranslation(TranslatedText.category)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        FloatingActionButton(
                            onPressed: () => _onSubmitted(state),
                            child: const Icon(Icons.add)),
                      ],
                    ),
                  ),
                ],
              ),
            ));
      },
    );
  }

  void _search() {
    final value = _cubit.state.creatingItemName.text.trim();
    value.isNotEmpty
        ? _cubit.setSearchResult(_cubit.state.currentHouseholdState.household!
            .search(value, _currentId))
        : _cubit.resetSearchResult();
  }

  void _onSubmitted(AppState state) async {
    final dbController = FirebaseController.instance;
    final name = state.creatingItemName.text.trim();
    state.creatingItemName.clear();
    if (state.creatingItem) {
      final item = await dbController.addItem(name, _currentId);
      if (item != null && state.categoryRecommendations) {
        final categories = state
                .currentHouseholdState.household?.categories.values
                .where((e) => e.id >= 0 && !e.isDeleted)
                .toList() ??
            [];
        if (categories.isNotEmpty) {
          findBestCategory(item, categories).then((match) {
            if (context.mounted) {
              showDialog(
                  context: context,
                  useRootNavigator: false,
                  builder: (context) => PopScope(
                        canPop: false,
                        child: AlertDialog(
                          title: Text(
                              "${_cubit.getTranslation(TranslatedText.categoryMatch)} (${item.name})"),
                          content: RowCard(
                            imageUrl: match.image.url,
                            aspectRatio: 5 / 3,
                            height: 80,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    match.name,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ),
                              )
                            ],
                          ),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(_cubit
                                    .getTranslation(TranslatedText.decline))),
                            TextButton(
                                onPressed: () {
                                  dbController.changeItemParent(item, match.id);
                                  Navigator.pop(context);
                                },
                                child: Text(_cubit
                                    .getTranslation(TranslatedText.accept))),
                          ],
                        ),
                      ));
            }
          });
        }
      }
    } else {
      dbController.addCategory(name, _currentId);
    }
  }

  Widget _categoryRow(
      BuildContext context, Function setState, Category category) {
    const height = 80.0;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          RowCard(
            imageUrl: category.image.url,
            aspectRatio: 5 / 3,
            height: height,
            onTap: () {
              setState(() {
                _currentId = category.id;
                _search();
              });
            },
            onLongPress: () async {
              _showCategoryMenu(context, category);
            },
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: AutoSizeText(
                  category.name,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          IconButton(
              onPressed: () async {
                _showCategoryMenu(context, category);
              },
              icon: const Icon(Icons.menu, size: 16)),
        ],
      ),
    );
  }

  void _showCategoryMenu(BuildContext context, Category category) {
    showDialog(
        context: context,
        useRootNavigator: false,
        builder: (context) => MenuDialog(
              name: category.name,
              ignoredId: category.id,
              changeName: (name) async {
                await FirebaseController.instance
                    .changeCategoryName(category, name);
              },
              changeImage: (image) async {
                await FirebaseController.instance
                    .swapCategoryImage(category, image);
              },
              changeParent: (parentId) async {
                _currentId = parentId;
                await FirebaseController.instance
                    .changeCategoryParent(category, parentId);
              },
              delete: () async {
                final answer = await showDialog(
                        context: context,
                        useRootNavigator: false,
                        builder: (context) => ConfirmationAlert(
                            question: _cubit
                                .getTranslation(TranslatedText.areYouSure))) ??
                    false;
                if (answer) {
                  FirebaseController.instance.removeCategory(category);
                }
                return answer;
              },
            ));
  }

  _setParent(int parentId) {
    _currentId = parentId;
  }
}

Widget itemCard(BuildContext context, Item item, bool clickable, bool selecting,
    [void Function(int)? setParent]) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Stack(
      alignment: Alignment.topRight,
      children: [
        GestureDetector(
          onTap: () {
            if (clickable) {
              if (selecting) {
                Navigator.of(context).pop(item);
              } else {
                showDialog(
                    context: context,
                    useRootNavigator: false,
                    builder: (context) {
                      final screenSize = MediaQuery.of(context).size;
                      final size =
                          min(screenSize.width, screenSize.height) - 64;
                      return Center(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: size,
                                height: size,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child:
                                      itemCard(context, item, false, selecting),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    });
              }
            }
          },
          onLongPress: clickable
              ? () async {
                  _showItemMenu(context, item, setParent);
                }
              : null,
          child: Container(
            decoration: BoxDecoration(
                color: cardColor(context),
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 5.0,
                    spreadRadius: 1.0,
                    color: shadowColor,
                  )
                ]),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(10)),
                  child: FadeInNetworkImage(
                      imageUrl: item.image.url, aspectRatio: 4 / 3),
                ),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: AutoSizeText(
                        item.name,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        if (clickable)
          IconButton(
              onPressed: () {
                _showItemMenu(context, item, setParent);
              },
              icon: const Icon(Icons.menu, size: 16)),
      ],
    ),
  );
}

void _showItemMenu(BuildContext context, Item item,
    [void Function(int)? setParent]) {
  showDialog(
      context: context,
      useRootNavigator: false,
      builder: (context) => MenuDialog(
            name: item.name,
            changeName: (name) async {
              await FirebaseController.instance.changeItemName(item, name);
            },
            changeImage: (image) async {
              await FirebaseController.instance.swapItemImage(item, image);
            },
            changeParent: (parentId) async {
              if (setParent != null) setParent(parentId);
              await FirebaseController.instance
                  .changeItemParent(item, parentId);
            },
            delete: () async {
              FirebaseController.instance.removeItem(item);
              return true;
            },
          ));
}
