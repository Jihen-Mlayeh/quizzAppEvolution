import 'package:flutter/material.dart';

import '../../../data/repositories/firestore_seeder.dart';
import '../../../data/repositories/quiz_repository.dart';
import 'add_question_page.dart';
import 'manage_question_page.dart';


/// Page d'administration pour gérer les questions du quiz
///
/// Cette page permet de :
/// - Peupler la base de données avec des questions initiales
/// - Ajouter de nouvelles questions
/// - Gérer les questions existantes
class AdminHomePage extends StatefulWidget {
  final QuizRepository repository;

  const AdminHomePage({
    Key? key,
    required this.repository,
  }) : super(key: key);

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _questionsCount = 0;
  List<String> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);

    final count = await widget.repository.getQuestionsCount();
    final categories = await widget.repository.getCategories();

    setState(() {
      _questionsCount = count;
      _categories = categories;
      _isLoading = false;
    });
  }

  Future<void> _seedDatabase() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Peupler la base de données'),
        content: const Text(
          'Cette action ajoutera des questions initiales à la base de données.\n\n'
              'Voulez-vous continuer ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final seeder = FirestoreSeeder(widget.repository);
    final success = await seeder.seedDatabase();

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

      if (success) {
        _loadStats();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administration Quiz'),
        backgroundColor: const Color(0xFFa855f7),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Statistiques
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Statistiques',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.quiz, color: Color(0xFFa855f7)),
                        const SizedBox(width: 12),
                        Text(
                          '$_questionsCount questions au total',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.category, color: Color(0xFFa855f7)),
                        const SizedBox(width: 12),
                        Text(
                          '${_categories.length} catégories',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    if (_categories.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _categories.map((category) {
                          return Chip(
                            label: Text(category),
                            backgroundColor: const Color(0xFFe0c3fc),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Actions
            const Text(
              'Actions',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Bouton: Peupler la base
            if (_questionsCount == 0)
              ElevatedButton.icon(
                onPressed: _seedDatabase,
                icon: const Icon(Icons.cloud_upload),
                label: const Text('Peupler la base de données'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10b981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(20),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),

            if (_questionsCount > 0) ...[
              // Bouton: Ajouter une question
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddQuestionPage(
                        repository: widget.repository,
                      ),
                    ),
                  );

                  if (result == true) {
                    _loadStats();
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Ajouter une question'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFa855f7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(20),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 12),

              // Bouton: Gérer les questions
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ManageQuestionsPage(
                        repository: widget.repository,
                      ),
                    ),
                  );

                  if (result == true) {
                    _loadStats();
                  }
                },
                icon: const Icon(Icons.edit),
                label: const Text('Gérer les questions'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3b82f6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(20),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
