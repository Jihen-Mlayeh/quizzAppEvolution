import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../business_logic/blocs/quiz_bloc.dart';
import '../../business_logic/blocs/quiz_state.dart';
import '../../business_logic/events/quiz_event.dart';
import '../../data/repositories/quiz_repository.dart'; // ← AJOUT
import '../animations/animated_background.dart';
import 'home_page.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AnimatedBackground(),
          SafeArea(
            child: BlocBuilder<QuizBloc, QuizState>(
              builder: (context, state) {
                if (state is! QuizCompleted) {
                  return const Center(child: CircularProgressIndicator());
                }

                final percentage = (state.score / state.total) * 100;

                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ... votre code existant pour l'affichage du score

                          const SizedBox(height: 32),

                          // ✅ BOUTON RECOMMENCER CORRIGÉ
                          ElevatedButton.icon(
                            onPressed: () {
                              // Récupérer le repository AVANT de naviguer
                              final repository = context.read<QuizBloc>().repository;

                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (newContext) => BlocProvider(
                                    create: (newContext) => QuizBloc(
                                      repository: repository,
                                    )..add(LoadQuizEvent()),
                                    child: const HomePage(),
                                  ),
                                ),
                                    (route) => false,
                              );
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Recommencer'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFa855f7),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}