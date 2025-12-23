import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/quiz_repository.dart';
import '../../data/models/question_model.dart';
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

  void _onLoadQuiz(LoadQuizEvent event, Emitter<QuizState> emit) {
    emit(QuizLoading());
    final questions = repository.getQuestions();
    emit(QuizLoaded(
      questions: questions,
      currentIndex: 0,
      score: 0,
      answers: [],
    ));
  }

  void _onAnswerQuestion(AnswerQuestionEvent event, Emitter<QuizState> emit) async {
    if (state is QuizLoaded) {
      final currentState = state as QuizLoaded;
      final currentQuestion = currentState.questions[currentState.currentIndex];
      final isCorrect = event.answer == currentQuestion.answer;

      final newAnswer = AnswerModel(
        questionId: currentQuestion.id,
        userAnswer: event.answer,
        isCorrect: isCorrect,
      );

      emit(currentState.copyWith(
        answers: [...currentState.answers, newAnswer],
        score: isCorrect ? currentState.score + 1 : currentState.score,
        showResult: true,
      ));

      // Auto next question after 1.5 seconds
      await Future.delayed(const Duration(milliseconds: 1500));
      add(NextQuestionEvent());
    }
  }

  void _onNextQuestion(NextQuestionEvent event, Emitter<QuizState> emit) {
    if (state is QuizLoaded) {
      final currentState = state as QuizLoaded;

      if (currentState.currentIndex < currentState.questions.length - 1) {
        emit(currentState.copyWith(
          currentIndex: currentState.currentIndex + 1,
          showResult: false,
        ));
      } else {
        emit(QuizCompleted(
          score: currentState.score,
          total: currentState.questions.length,
          answers: currentState.answers,
        ));
      }
    }
  }

  void _onResetQuiz(ResetQuizEvent event, Emitter<QuizState> emit) {
    add(LoadQuizEvent());
  }
}