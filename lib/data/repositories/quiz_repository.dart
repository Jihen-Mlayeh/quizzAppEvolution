import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/question_model.dart';

/// Repository pour gérer les questions du quiz avec Firestore
///
/// Ce repository fait le lien entre l'application et Firebase Firestore
/// Il gère toutes les opérations CRUD (Create, Read, Update, Delete)
class QuizRepository {
  // Instance de Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Nom de la collection dans Firestore
  static const String _collectionName = 'questions';

  /// ========================================
  /// LECTURE DES DONNÉES (READ)
  /// ========================================

  /// Récupérer toutes les questions depuis Firestore
  ///
  /// Retourne un Stream qui écoute les changements en temps réel
  Stream<List<QuestionModel>> getQuestionsStream() {
    return _firestore
        .collection(_collectionName)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => QuestionModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Récupérer toutes les questions (une seule fois)
  ///
  /// Utilisé pour obtenir les questions sans écouter les changements
  Future<List<QuestionModel>> getQuestions() async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .orderBy('createdAt', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => QuestionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ Erreur lors de la récupération des questions: $e');
      return [];
    }
  }

  /// Récupérer une question par son ID
  Future<QuestionModel?> getQuestionById(String id) async {
    try {
      final doc = await _firestore
          .collection(_collectionName)
          .doc(id)
          .get();

      if (doc.exists) {
        return QuestionModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('❌ Erreur lors de la récupération de la question: $e');
      return null;
    }
  }

  /// Récupérer des questions aléatoires
  Future<List<QuestionModel>> getRandomQuestions(int count) async {
    try {
      final allQuestions = await getQuestions();
      allQuestions.shuffle();
      return allQuestions.take(count).toList();
    } catch (e) {
      print('❌ Erreur lors de la récupération des questions aléatoires: $e');
      return [];
    }
  }

  /// Récupérer les questions par catégorie
  Future<List<QuestionModel>> getQuestionsByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('category', isEqualTo: category)
          .orderBy('createdAt', descending: false)
          .get();

      return snapshot.docs
          .map((doc) => QuestionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('❌ Erreur lors de la récupération des questions par catégorie: $e');
      return [];
    }
  }

  /// Obtenir toutes les catégories disponibles
  Future<List<String>> getCategories() async {
    try {
      final questions = await getQuestions();
      return questions
          .map((q) => q.category)
          .toSet()
          .toList()
        ..sort();
    } catch (e) {
      print('❌ Erreur lors de la récupération des catégories: $e');
      return [];
    }
  }

  /// ========================================
  /// CRÉATION DE DONNÉES (CREATE)
  /// ========================================

  /// Ajouter une nouvelle question à Firestore
  ///
  /// Retourne l'ID de la question créée ou null en cas d'erreur
  Future<String?> addQuestion(QuestionModel question) async {
    try {
      final docRef = await _firestore
          .collection(_collectionName)
          .add(question.toFirestore());

      print('✅ Question ajoutée avec succès (ID: ${docRef.id})');
      return docRef.id;
    } catch (e) {
      print('❌ Erreur lors de l\'ajout de la question: $e');
      return null;
    }
  }

  /// Ajouter plusieurs questions en batch
  Future<bool> addQuestions(List<QuestionModel> questions) async {
    try {
      final batch = _firestore.batch();

      for (var question in questions) {
        final docRef = _firestore.collection(_collectionName).doc();
        batch.set(docRef, question.toFirestore());
      }

      await batch.commit();
      print('✅ ${questions.length} questions ajoutées avec succès');
      return true;
    } catch (e) {
      print('❌ Erreur lors de l\'ajout des questions: $e');
      return false;
    }
  }

  /// ========================================
  /// MISE À JOUR DE DONNÉES (UPDATE)
  /// ========================================

  /// Mettre à jour une question existante
  Future<bool> updateQuestion(QuestionModel question) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(question.id)
          .update(question.toFirestore());

      print('✅ Question mise à jour avec succès (ID: ${question.id})');
      return true;
    } catch (e) {
      print('❌ Erreur lors de la mise à jour de la question: $e');
      return false;
    }
  }

  /// ========================================
  /// SUPPRESSION DE DONNÉES (DELETE)
  /// ========================================

  /// Supprimer une question
  Future<bool> deleteQuestion(String id) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(id)
          .delete();

      print('✅ Question supprimée avec succès (ID: $id)');
      return true;
    } catch (e) {
      print('❌ Erreur lors de la suppression de la question: $e');
      return false;
    }
  }

  /// Supprimer toutes les questions d'une catégorie
  Future<bool> deleteQuestionsByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('category', isEqualTo: category)
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('✅ Questions de la catégorie "$category" supprimées');
      return true;
    } catch (e) {
      print('❌ Erreur lors de la suppression des questions: $e');
      return false;
    }
  }

  /// ========================================
  /// UTILITAIRES
  /// ========================================

  /// Compter le nombre total de questions
  Future<int> getQuestionsCount() async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('❌ Erreur lors du comptage des questions: $e');
      return 0;
    }
  }

  /// Compter le nombre de questions par catégorie
  Future<int> getQuestionCountByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('category', isEqualTo: category)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('❌ Erreur lors du comptage des questions: $e');
      return 0;
    }
  }
}