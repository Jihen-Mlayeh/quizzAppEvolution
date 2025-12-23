import 'package:cloud_firestore/cloud_firestore.dart';

/// Modèle de données pour une question du quiz
///
/// Ce modèle représente une question avec ses propriétés et
/// permet la sérialisation/désérialisation depuis/vers Firestore
class QuestionModel {
  final String id;           // ID unique (généré par Firestore)
  final String question;     // Texte de la question
  final String imageUrl;     // URL de l'image (peut être locale ou Firebase Storage)
  final bool answer;         // Réponse correcte (true ou false)
  final String category;     // Catégorie de la question
  final DateTime createdAt;  // Date de création

  QuestionModel({
    required this.id,
    required this.question,
    required this.imageUrl,
    required this.answer,
    required this.category,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Créer un QuestionModel depuis un document Firestore
  ///
  /// Exemple de document Firestore :
  /// {
  ///   'question': 'La France a...',
  ///   'imageUrl': 'assets/images/...',
  ///   'answer': true,
  ///   'category': 'Histoire',
  ///   'createdAt': Timestamp(...)
  /// }
  factory QuestionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return QuestionModel(
      id: doc.id,  // L'ID du document Firestore
      question: data['question'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      answer: data['answer'] ?? false,
      category: data['category'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Créer un QuestionModel depuis un Map JSON
  /// Utile pour les données locales ou API REST
  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id']?.toString() ?? '',
      question: json['question'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      answer: json['answer'] ?? false,
      category: json['category'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  /// Convertir le modèle en Map pour Firestore
  ///
  /// Note: On n'inclut pas 'id' car Firestore gère les IDs automatiquement
  Map<String, dynamic> toFirestore() {
    return {
      'question': question,
      'imageUrl': imageUrl,
      'answer': answer,
      'category': category,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Convertir le modèle en Map JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'imageUrl': imageUrl,
      'answer': answer,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Créer une copie du modèle avec des modifications
  QuestionModel copyWith({
    String? id,
    String? question,
    String? imageUrl,
    bool? answer,
    String? category,
    DateTime? createdAt,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      question: question ?? this.question,
      imageUrl: imageUrl ?? this.imageUrl,
      answer: answer ?? this.answer,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'QuestionModel(id: $id, question: $question, category: $category, answer: $answer)';
  }
}