import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groceries_app/logic/state_cubit.dart';
import 'package:groceries_app/widget/options_button.dart';
import 'package:groceries_app/widget/row_card.dart';

class CategorySelectPage extends StatefulWidget {
  final int initialId;
  final int? ignoreId;

  const CategorySelectPage({super.key, this.initialId = -1, this.ignoreId});

  @override
  State<CategorySelectPage> createState() => _CategorySelectPageState();
}

class _CategorySelectPageState extends State<CategorySelectPage> {
  late int _currentId;

  @override
  void initState() {
    super.initState();
    _currentId = widget.initialId;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StateCubit, AppState>(builder: (context, state) {
      final household = state.currentHouseholdState.household!;
      final categories = household
          .getCategories(_currentId)
          .where((e) => widget.ignoreId == null || e.id != widget.ignoreId)
          .toList();
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (popped, result) {
          if (popped) return;
          if (_currentId == -1) {
            Navigator.pop(context);
            return;
          }
          setState(() {
            final category = household.categories[_currentId]!;
            _currentId = category.parentId;
          });
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(household.categories[_currentId]!.name),
            actions: const [OptionsButton()],
          ),
          body: ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, i) {
              final category = categories[i];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: RowCard(
                  imageUrl: category.image.url,
                  aspectRatio: 5 / 3,
                  height: 80,
                  onTap: () {
                    setState(() {
                      _currentId = category.id;
                    });
                  },
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        category.name,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).pop(_currentId);
              },
              child: const Icon(Icons.upload)),
        ),
      );
    });
  }
}
