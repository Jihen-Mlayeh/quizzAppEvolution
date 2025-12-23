import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/quiz_provider.dart';
import '../widgets/question_card_provider.dart';
import '../widgets/progress_bar.dart';
import '../animations/animated_background.dart';
import 'result_page_provider.dart';

class HomePageProvider extends StatelessWidget {
  const HomePageProvider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AnimatedBackground(),
          SafeArea(
            child: Consumer<QuizProvider>(
              builder: (context, quizProvider, child) {
                // Si le quiz est terminé, navigue vers la page de résultats
                if (quizProvider.isCompleted) {
                  // Utilise addPostFrameCallback pour éviter de modifier l'état pendant build
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const ResultPageProvider(),
                      ),
                    );
                  });
                }

                // Affiche un loader pendant le chargement
                if (quizProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  );
                }

                // Affiche le quiz
                return Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Titre avec dégradé
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

                          // Informations (Question actuelle et Score)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Question ${quizProvider.currentQuestionIndex + 1}/${quizProvider.totalQuestions}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'Score: ${quizProvider.score}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Barre de progression
                          ProgressBar(
                            current: quizProvider.currentQuestionIndex + 1,
                            total: quizProvider.totalQuestions,
                          ),
                        ],
                      ),
                    ),

                    // Question Card
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          child: QuestionCardProvider(
                            question: quizProvider.currentQuestion!,
                            onAnswer: (answer) {
                              quizProvider.answerQuestion(answer);
                            },
                            showResult: quizProvider.showResult,
                            lastAnswer: quizProvider.lastAnswer,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}