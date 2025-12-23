class AnswerModel {
  final int questionId;
  final bool userAnswer;
  final bool isCorrect;

  AnswerModel({
    required this.questionId,
    required this.userAnswer,
    required this.isCorrect,
  });
}