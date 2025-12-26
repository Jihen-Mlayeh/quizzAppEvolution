import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../business_logic/blocs/quiz_bloc.dart';
import '../../business_logic/blocs/quiz_state.dart';
import '../../business_logic/events/quiz_event.dart';
import '../../business_logic/auth/auth_bloc.dart';
import '../../business_logic/auth/auth_event.dart';
import '../animations/animated_background.dart';
import 'home_page.dart';

class ResultPageComplete extends StatefulWidget {
  const ResultPageComplete({Key? key}) : super(key: key);

  @override
  State<ResultPageComplete> createState() => _ResultPageCompleteState();
}

class _ResultPageCompleteState extends State<ResultPageComplete> {
  bool _statsUpdated = false;

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

                // ✅ MISE À JOUR DES STATISTIQUES
                if (!_statsUpdated) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      print('📊 Mise à jour des statistiques: ${state.score}/${state.total}');
                      context.read<AuthBloc>().add(
                        UpdateQuizStatsRequested(
                          score: state.score,
                          total: state.total,
                        ),
                      );
                      setState(() {
                        _statsUpdated = true;
                      });
                    }
                  });
                }

                final percentage = (state.score / state.total) * 100;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // CARTE DE SCORE PRINCIPAL
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFfbbf24),
                                    Color(0xFFf97316),
                                  ],
                                ),
                              ),
                              child: const Icon(
                                Icons.emoji_events,
                                size: 64,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Quiz Terminé !',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  ShaderMask(
                                    shaderCallback: (bounds) =>
                                        const LinearGradient(
                                          colors: [
                                            Color(0xFFec4899),
                                            Color(0xFFa855f7),
                                            Color(0xFF6366f1),
                                          ],
                                        ).createShader(bounds),
                                    child: Text(
                                      '${state.score}/${state.total}',
                                      style: const TextStyle(
                                        fontSize: 64,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Score: ${percentage.toStringAsFixed(0)}%',
                                    style: TextStyle(
                                      fontSize: 24,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              percentage >= 80
                                  ? '🎉 Excellent ! Vous maîtrisez parfaitement le sujet !'
                                  : percentage >= 60
                                  ? '👍 Bien joué ! Quelques révisions et ce sera parfait !'
                                  : '💪 Continuez à apprendre, vous progressez !',
                              style: TextStyle(
                                fontSize: 18,
                                color: percentage >= 80
                                    ? Colors.greenAccent
                                    : percentage >= 60
                                    ? Colors.yellowAccent
                                    : Colors.orangeAccent,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // DÉTAILS DES RÉPONSES
                      const Text(
                        'Détails des réponses',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Afficher chaque réponse
                      ...state.answers.asMap().entries.map((entry) {
                        final index = entry.key;
                        final answer = entry.value;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: answer.isCorrect
                                ? Colors.green.withOpacity(0.2)
                                : Colors.red.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: answer.isCorrect
                                  ? Colors.green.withOpacity(0.5)
                                  : Colors.red.withOpacity(0.5),
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                answer.isCorrect
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: answer.isCorrect ? Colors.green : Colors.red,
                                size: 32,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Question ${index + 1}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      answer.isCorrect
                                          ? '✅ Bonne réponse !'
                                          : '❌ Mauvaise réponse',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: answer.userAnswer
                                      ? Colors.green.withOpacity(0.3)
                                      : Colors.red.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  answer.userAnswer ? 'VRAI' : 'FAUX',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),

                      const SizedBox(height: 32),

                      // BOUTON RECOMMENCER
                      ElevatedButton.icon(
                        onPressed: () {
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
                        label: const Text('Recommencer le quiz'),
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

                      const SizedBox(height: 16),
                    ],
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