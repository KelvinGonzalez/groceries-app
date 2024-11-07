import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:groceries_app/logic/state_cubit.dart';
import 'package:groceries_app/page/households.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyDNX3rUvsJ_Gs8s3siA_ZJF_JJPBJrfXSg",
          projectId: "groceries-app-47bb0",
          messagingSenderId: "657535635356",
          appId: kIsWeb
              ? "1:657535635356:web:03d27ae8d774be99304259"
              : "1:657535635356:android:f7a87d80b475fa14304259"));
  final cubit = StateCubit()..init();
  runApp(MyApp(cubit: cubit));
}

class MyApp extends StatelessWidget {
  final StateCubit cubit;

  const MyApp({super.key, required this.cubit});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => cubit,
      child: BlocBuilder<StateCubit, AppState>(builder: (context, state) {
        return MaterialApp(
            title: 'Groceries App',
            theme: ThemeData(
              colorScheme: state.isDarkMode
                  ? const ColorScheme.dark()
                  : const ColorScheme.light(),
              useMaterial3: true,
            ),
            debugShowCheckedModeBanner: false,
            home: const HouseholdsPage());
      }),
    );
  }
}
