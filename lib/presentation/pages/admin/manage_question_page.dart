import 'package:flutter/material.dart';

import '../../../data/models/question_model.dart';
import '../../../data/repositories/quiz_repository.dart';


/// Page pour gérer (voir, modifier, supprimer) les questions existantes
class ManageQuestionsPage extends StatefulWidget {
  final QuizRepository repository;

  const ManageQuestionsPage({
    Key? key,
    required this.repository,
  }) : super(key: key);

  @override
  State<ManageQuestionsPage> createState() => _ManageQuestionsPageState();
}

class _ManageQuestionsPageState extends State<ManageQuestionsPage> {
  List<QuestionModel> _questions = [];
  List<QuestionModel> _filteredQuestions = [];
  String? _selectedCategory;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() => _isLoading = true);

    final questions = await widget.repository.getQuestions();

    setState(() {
      _questions = questions;
      _filteredQuestions = questions;
      _isLoading = false;
    });
  }

  void _filterByCategory(String? category) {
    setState(() {
      _selectedCategory = category;
      if (category == null) {
        _filteredQuestions = _questions;
      } else {
        _filteredQuestions = _questions
            .where((q) => q.category == category)
            .toList();
      }
    });
  }

  Future<void> _deleteQuestion(QuestionModel question) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la question'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer cette question ?\n\n'
              '"${question.question}"',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success = await widget.repository.deleteQuestion(question.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? '✅ Question supprimée avec succès'
                : '❌ Erreur lors de la suppression',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );

      if (success) {
        _loadQuestions();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtenir toutes les catégories uniques
    final categories = _questions
        .map((q) => q.category)
        .toSet()
        .toList()
      ..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gérer les questions'),
        backgroundColor: const Color(0xFFa855f7),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadQuestions,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Filtre par catégorie
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              children: [
                const Text(
                  'Filtrer par:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('Toutes'),
                          selected: _selectedCategory == null,
                          onSelected: (_) => _filterByCategory(null),
                          selectedColor: const Color(0xFFa855f7),
                          labelStyle: TextStyle(
                            color: _selectedCategory == null
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ...categories.map((category) {
                          final count = _questions
                              .where((q) => q.category == category)
                              .length;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text('$category ($count)'),
                              selected: _selectedCategory == category,
                              onSelected: (_) => _filterByCategory(category),
                              selectedColor: const Color(0xFFa855f7),
                              labelStyle: TextStyle(
                                color: _selectedCategory == category
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Liste des questions
          Expanded(
            child: _filteredQuestions.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.quiz_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune question trouvée',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredQuestions.length,
              itemBuilder: (context, index) {
                final question = _filteredQuestions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: question.answer
                          ? Colors.green
                          : Colors.red,
                      child: Text(
                        question.answer ? 'V' : 'F',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      question.question,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Chip(
                            label: Text(
                              question.category,
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: const Color(0xFFe0c3fc),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                          ),
                        ],
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Bouton: Voir détails
                        IconButton(
                          icon: const Icon(Icons.visibility),
                          onPressed: () {
                            _showQuestionDetails(question);
                          },
                          tooltip: 'Voir détails',
                        ),
                        // Bouton: Supprimer
                        IconButton(
                          icon: const Icon(Icons.delete),
                          color: Colors.red,
                          onPressed: () {
                            _deleteQuestion(question);
                          },
                          tooltip: 'Supprimer',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Barre du bas: Statistiques
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${_questions.length}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFa855f7),
                      ),
                    ),
                    const Text('Total'),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${_filteredQuestions.length}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3b82f6),
                      ),
                    ),
                    const Text('Affichées'),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${categories.length}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF10b981),
                      ),
                    ),
                    const Text('Catégories'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showQuestionDetails(QuestionModel question) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Détails de la question'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _DetailRow(label: 'ID', value: question.id),
              const SizedBox(height: 12),
              _DetailRow(label: 'Question', value: question.question),
              const SizedBox(height: 12),
              _DetailRow(label: 'Catégorie', value: question.category),
              const SizedBox(height: 12),
              _DetailRow(
                label: 'Réponse',
                value: question.answer ? 'VRAI' : 'FAUX',
                valueColor: question.answer ? Colors.green : Colors.red,
              ),
              const SizedBox(height: 12),
              _DetailRow(label: 'Image', value: question.imageUrl),
              const SizedBox(height: 12),
              _DetailRow(
                label: 'Créée le',
                value: '${question.createdAt.day}/${question.createdAt.month}/${question.createdAt.year}',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}
