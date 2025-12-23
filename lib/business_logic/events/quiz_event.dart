import 'package:equatable/equatable.dart';

abstract class QuizEvent extends Equatable {
  const QuizEvent();

  @override
  List<Object> get props => [];
}

class LoadQuizEvent extends QuizEvent {}

class AnswerQuestionEvent extends QuizEvent {
  final bool answer;

  const AnswerQuestionEvent(this.answer);

  @override
  List<Object> get props => [answer];
}

class NextQuestionEvent extends QuizEvent {}

class ResetQuizEvent extends QuizEvent {}