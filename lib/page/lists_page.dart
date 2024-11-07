import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groceries_app/logic/firebase_controller.dart';
import 'package:groceries_app/logic/state_cubit.dart';
import 'package:groceries_app/page/list_page.dart';
import 'package:groceries_app/widget/confirmation_alert.dart';
import 'package:groceries_app/widget/dark_mode_switch.dart';
import 'package:groceries_app/widget/row_card.dart';
import 'package:intl/intl.dart';

class ListsPage extends StatelessWidget {
  const ListsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StateCubit, AppState>(builder: (context, state) {
      final shoppingLists = state.currentHouseholdState.shoppingLists
              ?.where((e) => !e.isDeleted)
              .toList() ??
          [];
      return Scaffold(
        appBar: AppBar(
          title: const Text("Shopping Lists"),
          actions: const [DarkModeSwitch()],
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
                      ),
                      IconButton(
                          onPressed: () async {
                            final answer = await showDialog(
                                    context: context,
                                    useRootNavigator: false,
                                    builder: (context) =>
                                        const ConfirmationAlert(
                                            question: "Are you sure?")) ??
                                false;
                            if (answer) {
                              FirebaseController.instance
                                  .removeShoppingList(shoppingLists[i]);
                            }
                          },
                          icon: const Icon(Icons.close, size: 16)),
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
                      title: const Text("Create List"),
                      content: TextField(
                        controller: controller,
                        onSubmitted: (value) => _submit(context, value),
                        decoration:
                            const InputDecoration(hintText: "Enter name..."),
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
}
