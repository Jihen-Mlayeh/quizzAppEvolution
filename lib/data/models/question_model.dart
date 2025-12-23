class QuestionModel {
  final int id;
  final String question;
  final String imageUrl;
  final bool answer;
  final String category;

  QuestionModel({
    required this.id,
    required this.question,
    required this.imageUrl,
    required this.answer,
    required this.category,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'],
      question: json['question'],
      imageUrl: json['imageUrl'],
      answer: json['answer'],
      category: json['category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'imageUrl': imageUrl,
      'answer': answer,
      'category': category,
    };
  }
}

// IMPORTANT: AnswerModel doit être dans le même fichier
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