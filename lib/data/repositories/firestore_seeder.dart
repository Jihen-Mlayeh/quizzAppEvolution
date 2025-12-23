import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../repositories/quiz_repository.dart';

/// Service pour peupler la base de données Firestore
///
/// Cette classe contient les données initiales et permet de les insérer dans Firestore
class FirestoreSeeder {
  final QuizRepository _repository;

  FirestoreSeeder(this._repository);

  /// Liste des questions initiales
  ///
  /// Ces questions seront ajoutées à Firestore lors du premier lancement
  List<QuestionModel> _getInitialQuestions() {
    return [
      // QUESTIONS VRAIES - Histoire
      QuestionModel(
        id: '', // L'ID sera généré par Firestore
        question: "La France a dû céder l'Alsace et la Moselle à l'Allemagne après la guerre de 1870-1871.",
        imageUrl: "assets/images/alsace.jpg",
        answer: true,
        category: "Histoire",
      ),
      QuestionModel(
        id: '',
        question: "La Révolution française a commencé en 1789.",
        imageUrl: "assets/images/revolution.jpg",
        answer: true,
        category: "Histoire",
      ),
      QuestionModel(
        id: '',
        question: "Napoléon Bonaparte est né en France continentale.",
        imageUrl: "assets/images/napoleon.jpg",
        answer: false, // Il est né en Corse
        category: "Histoire",
      ),
      QuestionModel(
        id: '',
        question: "La Marseillaise a été écrite pendant la Révolution de 1848.",
        imageUrl: "assets/images/marseillaise.jpg",
        answer: false, // Elle a été écrite en 1792
        category: "Histoire",
      ),

      // QUESTIONS - Culture
      QuestionModel(
        id: '',
        question: "La Tour Eiffel a été construite en 1889 pour l'Exposition Universelle de Paris.",
        imageUrl: "assets/images/tour_eiffel.jpg",
        answer: true,
        category: "Culture",
      ),
      QuestionModel(
        id: '',
        question: "Victor Hugo a écrit 'Les Misérables'.",
        imageUrl: "assets/images/victor_hug.jpg",
        answer: true,
        category: "Culture",
      ),
      QuestionModel(
        id: '',
        question: "Le français est la langue officielle de la France.",
        imageUrl: "assets/images/langue.jpg",
        answer: true,
        category: "Culture",
      ),
      QuestionModel(
        id: '',
        question: "Le Louvre est le musée le plus visité au monde.",
        imageUrl: "assets/images/louvre.jpg",
        answer: true,
        category: "Culture",
      ),
      QuestionModel(
        id: '',
        question: "Molière est l'auteur de 'Le Tartuffe'.",
        imageUrl: "assets/images/moliere.jpg",
        answer: true,
        category: "Culture",
      ),

      // QUESTIONS - Géographie
      QuestionModel(
        id: '',
        question: "Le Mont Blanc est le plus haut sommet d'Europe.",
        imageUrl: "assets/images/mont_blanc.jpg",
        answer: true,
        category: "Géographie",
      ),
      QuestionModel(
        id: '',
        question: "La France compte 13 régions en métropole.",
        imageUrl: "assets/images/regions.jpg",
        answer: true,
        category: "Géographie",
      ),
      QuestionModel(
        id: '',
        question: "Paris est traversée par le fleuve Loire.",
        imageUrl: "assets/images/paris_seine.jpg",
        answer: false, // C'est la Seine
        category: "Géographie",
      ),
      QuestionModel(
        id: '',
        question: "La France a 8 pays frontaliers.",
        imageUrl: "assets/images/frontieres.jpg",
        answer: false, // Elle en a 11 (incluant les territoires d'outre-mer)
        category: "Géographie",
      ),
      QuestionModel(
        id: '',
        question: "Strasbourg est la capitale de l'Alsace.",
        imageUrl: "assets/images/strasbourg.jpg",
        answer: true,
        category: "Géographie",
      ),

      // QUESTIONS - Sport
      QuestionModel(
        id: '',
        question: "La France a remporté la Coupe du Monde de football 3 fois.",
        imageUrl: "assets/images/football.jpg",
        answer: false, // 2 fois : 1998 et 2018
        category: "Sport",
      ),
    ];
  }

  /// Peupler Firestore avec les questions initiales
  ///
  /// Retourne true si l'opération réussit, false sinon
  Future<bool> seedDatabase() async {
    try {
      print('🌱 Début du peuplement de la base de données...');

      // Vérifier si des questions existent déjà
      final existingCount = await _repository.getQuestionsCount();

      if (existingCount > 0) {
        print('⚠️  La base de données contient déjà $existingCount questions.');
        print('   Voulez-vous les remplacer ? (Cette action n\'est pas implémentée ici)');
        return false;
      }

      // Obtenir les questions initiales
      final questions = _getInitialQuestions();
      print('📝 ${questions.length} questions à ajouter...');

      // Ajouter les questions à Firestore
      final success = await _repository.addQuestions(questions);

      if (success) {
        print('✅ Base de données peuplée avec succès !');
        print('   Total: ${questions.length} questions ajoutées');

        // Afficher un résumé par catégorie
        final categories = questions.map((q) => q.category).toSet();
        for (var category in categories) {
          final count = questions.where((q) => q.category == category).length;
          print('   - $category: $count questions');
        }
      } else {
        print('❌ Échec du peuplement de la base de données');
      }

      return success;
    } catch (e) {
      print('❌ Erreur lors du peuplement: $e');
      return false;
    }
  }

  /// Réinitialiser la base de données (supprimer toutes les questions)
  ///
  /// ⚠️  Attention: Cette action est irréversible !
  Future<bool> clearDatabase() async {
    try {
      print('🗑️  Suppression de toutes les questions...');

      final questions = await _repository.getQuestions();

      for (var question in questions) {
        await _repository.deleteQuestion(question.id);
      }

      print('✅ Base de données vidée avec succès !');
      return true;
    } catch (e) {
      print('❌ Erreur lors de la suppression: $e');
      return false;
    }
  }

  /// Ajouter des questions supplémentaires à une catégorie
  Future<bool> addQuestionsToCategory(
      String category,
      List<QuestionModel> questions,
      ) async {
    try {
      print('➕ Ajout de ${questions.length} questions à la catégorie "$category"...');

      final success = await _repository.addQuestions(questions);

      if (success) {
        print('✅ Questions ajoutées avec succès !');
      }

      return success;
    } catch (e) {
      print('❌ Erreur lors de l\'ajout: $e');
      return false;
    }
  }
}

/// Widget pour afficher un bouton de peuplement (à utiliser en développement)
class SeedDatabaseButton extends StatefulWidget {
  final QuizRepository repository;

  const SeedDatabaseButton({
    Key? key,
    required this.repository,
  }) : super(key: key);

  @override
  State<SeedDatabaseButton> createState() => _SeedDatabaseButtonState();
}

class _SeedDatabaseButtonState extends State<SeedDatabaseButton> {
  bool _isSeeding = false;

  Future<void> _seedDatabase() async {
    setState(() => _isSeeding = true);

    final seeder = FirestoreSeeder(widget.repository);
    final success = await seeder.seedDatabase();

    setState(() => _isSeeding = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? '✅ Base de données peuplée avec succès !'
                : '❌ Échec du peuplement',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _isSeeding ? null : _seedDatabase,
      icon: _isSeeding
          ? const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      )
          : const Icon(Icons.cloud_upload),
      label: Text(_isSeeding ? 'Peuplement...' : 'Peupler la base'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFa855f7),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }
}
