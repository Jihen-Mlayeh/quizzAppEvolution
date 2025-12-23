import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/AnswerModel.dart';
import '../../data/repositories/quiz_repository.dart';

import 'quiz_state.dart';
import '../events/quiz_event.dart';

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  final QuizRepository repository;

  QuizBloc({required this.repository}) : super(QuizInitial()) {
    on<LoadQuizEvent>(_onLoadQuiz);
    on<AnswerQuestionEvent>(_onAnswerQuestion);
    on<NextQuestionEvent>(_onNextQuestion);
    on<ResetQuizEvent>(_onResetQuiz);
  }

  /// Charger les questions depuis Firestore
  Future<void> _onLoadQuiz(LoadQuizEvent event, Emitter<QuizState> emit) async {
    emit(QuizLoading());

    try {
      // Récupérer les questions depuis Firestore (async)
      final questions = await repository.getQuestions();

      if (questions.isEmpty) {
        emit(QuizError('Aucune question trouvée. Veuillez peupler la base de données.'));
        return;
      }

      emit(QuizLoaded(
        questions: questions,
        currentIndex: 0,
        score: 0,
        answers: [],
        showResult: false,
      ));
    } catch (e) {
      emit(QuizError('Erreur: $e'));
    }
  }

  /// Répondre à une question
  void _onAnswerQuestion(
      AnswerQuestionEvent event,
      Emitter<QuizState> emit,
      ) {
    if (state is! QuizLoaded) return;

    final currentState = state as QuizLoaded;
    final currentQuestion = currentState.questions[currentState.currentIndex];

    // Vérifier si la réponse est correcte
    final isCorrect = event.answer == currentQuestion.answer;

    // Créer l'objet Answer
    final answer = AnswerModel(
      questionId: currentQuestion.id,
      userAnswer: event.answer,
      isCorrect: isCorrect,
    );

    // Mettre à jour le score et les réponses
    final newScore = isCorrect ? currentState.score + 1 : currentState.score;
    final newAnswers = [...currentState.answers, answer];

    emit(QuizLoaded(
      questions: currentState.questions,
      currentIndex: currentState.currentIndex,
      score: newScore,
      answers: newAnswers,
      showResult: true, // Afficher le résultat
    ));
  }

  /// Passer à la question suivante
  void _onNextQuestion(
      NextQuestionEvent event,
      Emitter<QuizState> emit,
      ) {
    if (state is! QuizLoaded) return;

    final currentState = state as QuizLoaded;

    // Vérifier s'il reste des questions
    if (currentState.currentIndex < currentState.questions.length - 1) {
      // Passer à la question suivante
      emit(QuizLoaded(
        questions: currentState.questions,
        currentIndex: currentState.currentIndex + 1,
        score: currentState.score,
        answers: currentState.answers,
        showResult: false,
      ));
    } else {
      // Quiz terminé
      emit(QuizCompleted(
        total: currentState.questions.length,
        score: currentState.score,
        answers: currentState.answers,
      ));
    }
  }

  /// Réinitialiser le quiz
  void _onResetQuiz(
      ResetQuizEvent event,
      Emitter<QuizState> emit,
      ) {
    add(LoadQuizEvent());
  }
}