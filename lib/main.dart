import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data/repositories/quiz_repository.dart';
import 'business_logic/blocs/quiz_bloc.dart';
import 'business_logic/events/quiz_event.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/themes/app_theme.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/repositories/quiz_repository.dart';
import 'data/providers/quiz_provider.dart';
import 'presentation/pages/home_page_provider.dart';
import 'presentation/themes/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ChangeNotifierProvider permet d'injecter le Provider dans l'arbre de widgets
    return ChangeNotifierProvider(
      create: (context) => QuizProvider(
        repository: QuizRepository(),
      ),
      child: MaterialApp(
        title: 'Quiz France - Provider',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const HomePageProvider(),
      ),
    );
  }
}
/*void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => QuizBloc(
        repository: QuizRepository(),
      )..add(LoadQuizEvent()),
      child: MaterialApp(
        title: 'Quiz France',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const HomePage(),
      ),
    );
  }
}*/