import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groceries_app/logic/firebase_controller.dart';
import 'package:groceries_app/logic/state_cubit.dart';
import 'package:groceries_app/model/shopping_list.dart';
import 'package:groceries_app/model/translated_text.dart';
import 'package:groceries_app/page/list_page.dart';
import 'package:groceries_app/widget/confirmation_alert.dart';
import 'package:groceries_app/widget/options_button.dart';
import 'package:groceries_app/widget/menu_dialog.dart';
import 'package:groceries_app/widget/row_card.dart';
import 'package:intl/intl.dart';

class ListsPage extends StatelessWidget {
  const ListsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StateCubit, AppState>(builder: (context, state) {
      final cubit = context.read<StateCubit>();
      final shoppingLists = state.currentHouseholdState.shoppingLists
              ?.where((e) => !e.isDeleted)
              .toList() ??
          [];
      return Scaffold(
        appBar: AppBar(
          title: Text(cubit.getTranslation(TranslatedText.shoppingLists)),
          actions: const [OptionsButton()],
        ),
        body: ListView.builder(
            itemCount: shoppingLists.length,
            itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      NamedRowCard(
                        name: shoppingLists[i].name,
                        height: 80,
                        child: Text(DateFormat.yMMMMd()
                            .format(shoppingLists[i].timestamp.toDate())),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  ListPage(id: shoppingLists[i].id)));
                        },
                        onLongPress: () {
                          _showMenu(context, shoppingLists[i]);
                        },
                      ),
                      IconButton(
                          onPressed: () async {
                            _showMenu(context, shoppingLists[i]);
                          },
                          icon: const Icon(Icons.menu, size: 16)),
                    ],
                  ),
                )),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            final controller = TextEditingController();
            showDialog(
                context: context,
                useRootNavigator: false,
                builder: (context) => AlertDialog(
                      title:
                          Text(cubit.getTranslation(TranslatedText.createList)),
                      content: TextField(
                        controller: controller,
                        onSubmitted: (value) => _submit(context, value),
                        decoration: InputDecoration(
                            hintText:
                                cubit.getTranslation(TranslatedText.enterName)),
                      ),
                      actions: [
                        IconButton(
                            onPressed: () => _submit(context, controller.text),
                            icon: const Icon(Icons.add))
                      ],
                    ));
          },
          child: const Icon(Icons.add),
        ),
      );
    });
  }

  void _submit(BuildContext context, String value) {
    FirebaseController.instance.createShoppingList(value.trim());
    Navigator.pop(context);
  }

  void _showMenu(BuildContext context, ShoppingList shoppingList) {
    showDialog(
        context: context,
        useRootNavigator: false,
        builder: (context) => MenuDialog(
              name: shoppingList.name,
              changeName: (name) async {
                await FirebaseController.instance
                    .changeShoppingListName(shoppingList, name);
              },
              copy: (name) async {
                await FirebaseController.instance
                    .copyShoppingList(shoppingList, name);
              },
              delete: () async {
                final answer = await showDialog(
                        context: context,
                        useRootNavigator: false,
                        builder: (context) => ConfirmationAlert(
                            question: context
                                .read<StateCubit>()
                                .getTranslation(TranslatedText.areYouSure))) ??
                    false;
                if (answer) {
                  FirebaseController.instance.removeShoppingList(shoppingList);
                }
                return answer;
              },
            ));
  }
}
