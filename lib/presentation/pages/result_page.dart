import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../business_logic/blocs/quiz_bloc.dart';
import '../../business_logic/blocs/quiz_state.dart';
import '../../business_logic/events/quiz_event.dart';
import '../animations/animated_background.dart';
import 'home_page.dart'; // ← AJOUT : Import nécessaire

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
                          const SizedBox(height: 32),

                          // ========================================
                          // ✅ CORRECTION ICI
                          // ========================================
                          ElevatedButton.icon(
                            onPressed: () {
                              // Créer un nouveau BLoC avec les questions rechargées
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => BlocProvider(
                                    create: (context) => QuizBloc(
                                      repository: context.read<QuizBloc>().repository,
                                    )..add(LoadQuizEvent()),
                                    child: const HomePage(),
                                  ),
                                ),
                                    (route) => false, // Supprime toutes les routes précédentes
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