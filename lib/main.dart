import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'business_logic/auth/auth_bloc.dart';
import 'business_logic/auth/auth_event.dart';
import 'business_logic/auth/auth_state.dart';
import 'business_logic/blocs/quiz_bloc.dart';
import 'firebase_options.dart';
import 'data/repositories/quiz_repository.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/storage_repository.dart';


import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => QuizRepository()),
        RepositoryProvider(create: (_) => AuthRepository()),
        RepositoryProvider(create: (_) => StorageRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
              storageRepository: context.read<StorageRepository>(),
            )..add(AuthCheckRequested()),
          ),
          BlocProvider(
            create: (context) => QuizBloc(
              repository: context.read<QuizRepository>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Quiz App - Firebase',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          home: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthInitial || state is AuthLoading) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              } else if (state is Authenticated) {
                return const HomePage();
              } else {
                return const LoginPage();
              }
            },
          ),
        ),
      ),
    );
  }
}