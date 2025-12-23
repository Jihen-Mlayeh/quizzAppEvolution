import 'package:equatable/equatable.dart';
import '../../data/models/question_model.dart';

abstract class QuizState extends Equatable {
  const QuizState();

  @override
  List<Object> get props => [];
}

class QuizInitial extends QuizState {}

class QuizLoading extends QuizState {}

class QuizLoaded extends QuizState {
  final List<QuestionModel> questions;
  final int currentIndex;
  final int score;
  final List<AnswerModel> answers;
  final bool showResult;

  const QuizLoaded({
    required this.questions,
    required this.currentIndex,
    required this.score,
    required this.answers,
    this.showResult = false,
  });

  QuizLoaded copyWith({
    List<QuestionModel>? questions,
    int? currentIndex,
    int? score,
    List<AnswerModel>? answers,
    bool? showResult,
  }) {
    return QuizLoaded(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      score: score ?? this.score,
      answers: answers ?? this.answers,
      showResult: showResult ?? this.showResult,
    );
  }

  @override
  List<Object> get props => [questions, currentIndex, score, answers, showResult];
}

class QuizCompleted extends QuizState {
  final int score;
  final int total;
  final List<AnswerModel> answers;

  const QuizCompleted({
    required this.score,
    required this.total,
    required this.answers,
  });

  @override
  List<Object> get props => [score, total, answers];
}