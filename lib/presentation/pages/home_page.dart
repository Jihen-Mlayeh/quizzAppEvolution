import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../business_logic/blocs/quiz_bloc.dart';
import '../../business_logic/blocs/quiz_state.dart';
import '../../business_logic/events/quiz_event.dart';
import '../widgets/question_card.dart';
import '../widgets/progress_bar.dart';
import '../animations/animated_background.dart';

import 'admin/add_home_page.dart';
import 'result_page_complete.dart'; // ← CHANGEMENT ICI

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AnimatedBackground(),
          SafeArea(
            child: BlocConsumer<QuizBloc, QuizState>(
              listener: (context, state) {
                if (state is QuizCompleted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<QuizBloc>(),
                        child: const ResultPageComplete(), // ← CHANGEMENT ICI
                      ),
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is QuizInitial || state is QuizLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state is QuizError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.white70,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              final repository = context.read<QuizBloc>().repository;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AdminHomePage(
                                    repository: repository,
                                  ),
                                ),
                              ).then((_) {
                                // Recharger les questions après être revenu de l'admin
                                context.read<QuizBloc>().add(LoadQuizEvent());
                              });
                            },
                            icon: const Icon(Icons.admin_panel_settings),
                            label: const Text('Aller à l\'administration'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFa855f7),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is QuizLoaded) {
                  final currentQuestion = state.questions[state.currentIndex];
                  final lastAnswer =
                  state.answers.isNotEmpty ? state.answers.last : null;

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [
                                  Color(0xFFec4899),
                                  Color(0xFFa855f7),
                                  Color(0xFF6366f1),
                                ],
                              ).createShader(bounds),
                              child: const Text(
                                'Quiz France',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Testez vos connaissances sur la France',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Question ${state.currentIndex + 1}/${state.questions.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'Score: ${state.score}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ProgressBar(
                              current: state.currentIndex + 1,
                              total: state.questions.length,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: SingleChildScrollView(
                            child: QuestionCard(
                              question: currentQuestion,
                              onAnswer: (answer) async {
                                // Envoyer la réponse
                                context
                                    .read<QuizBloc>()
                                    .add(AnswerQuestionEvent(answer));

                                // Attendre 1.5 secondes pour que l'utilisateur voie le résultat
                                await Future.delayed(
                                    const Duration(milliseconds: 1500));

                                // Passer à la question suivante
                                if (context.mounted) {
                                  context
                                      .read<QuizBloc>()
                                      .add(NextQuestionEvent());
                                }
                              },
                              showResult: state.showResult,
                              lastAnswer: lastAnswer,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return const Center(
                  child: Text(
                    'Une erreur est survenue',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Builder(
        builder: (context) {
          return FloatingActionButton.extended(
            onPressed: () {
              final repository = context.read<QuizBloc>().repository;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AdminHomePage(
                    repository: repository,
                  ),
                ),
              ).then((_) {
                context.read<QuizBloc>().add(LoadQuizEvent());
              });
            },
            icon: const Icon(Icons.admin_panel_settings),
            label: const Text('Admin'),
            backgroundColor: const Color(0xFFa855f7),
          );
        },
      ),
    );
  }
}