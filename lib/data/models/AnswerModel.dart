/// Modèle de données pour une réponse de l'utilisateur
/// 
/// Ce modèle représente la réponse d'un utilisateur à une question
class AnswerModel {
  final String questionId;   // ID de la question répondue
  final bool userAnswer;     // Réponse donnée par l'utilisateur
  final bool isCorrect;      // Est-ce que la réponse est correcte ?
  final DateTime answeredAt; // Date/heure de la réponse

  AnswerModel({
    required this.questionId,
    required this.userAnswer,
    required this.isCorrect,
    DateTime? answeredAt,
  }) : answeredAt = answeredAt ?? DateTime.now();

  /// Créer un AnswerModel depuis un Map JSON
  factory AnswerModel.fromJson(Map<String, dynamic> json) {
    return AnswerModel(
      questionId: json['questionId'] ?? '',
      userAnswer: json['userAnswer'] ?? false,
      isCorrect: json['isCorrect'] ?? false,
      answeredAt: json['answeredAt'] != null
          ? DateTime.parse(json['answeredAt'])
          : DateTime.now(),
    );
  }

  /// Convertir le modèle en Map JSON
  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'userAnswer': userAnswer,
      'isCorrect': isCorrect,
      'answeredAt': answeredAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'AnswerModel(questionId: $questionId, userAnswer: $userAnswer, isCorrect: $isCorrect)';
  }
}
