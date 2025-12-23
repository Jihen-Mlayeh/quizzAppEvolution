import 'package:flutter/material.dart';

import '../../../data/models/question_model.dart';
import '../../../data/repositories/quiz_repository.dart';


/// Page pour ajouter une nouvelle question au quiz
class AddQuestionPage extends StatefulWidget {
  final QuizRepository repository;

  const AddQuestionPage({
    Key? key,
    required this.repository,
  }) : super(key: key);

  @override
  State<AddQuestionPage> createState() => _AddQuestionPageState();
}

class _AddQuestionPageState extends State<AddQuestionPage> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _categoryController = TextEditingController();

  bool _answer = true;
  bool _isLoading = false;
  List<String> _existingCategories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await widget.repository.getCategories();
    setState(() {
      _existingCategories = categories;
    });
  }

  @override
  void dispose() {
    _questionController.dispose();
    _imageUrlController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _submitQuestion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final question = QuestionModel(
      id: '', // Sera généré par Firestore
      question: _questionController.text.trim(),
      imageUrl: _imageUrlController.text.trim(),
      answer: _answer,
      category: _categoryController.text.trim(),
    );

    final questionId = await widget.repository.addQuestion(question);

    setState(() => _isLoading = false);

    if (mounted) {
      if (questionId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Question ajoutée avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Erreur lors de l\'ajout de la question'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter une question'),
        backgroundColor: const Color(0xFFa855f7),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Champ: Question
              TextFormField(
                controller: _questionController,
                decoration: const InputDecoration(
                  labelText: 'Question *',
                  hintText: 'Entrez la question...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.help_outline),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer une question';
                  }
                  if (value.trim().length < 10) {
                    return 'La question doit contenir au moins 10 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Champ: URL de l'image
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL de l\'image *',
                  hintText: 'assets/images/exemple.jpg',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.image),
                  helperText: 'Chemin vers l\'image (assets/ ou URL)',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer l\'URL de l\'image';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Champ: Catégorie (avec suggestions)
              Autocomplete<String>(
                optionsBuilder: (textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return _existingCategories;
                  }
                  return _existingCategories.where((category) {
                    return category
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase());
                  });
                },
                fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                  _categoryController.text = controller.text;
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Catégorie *',
                      hintText: 'Histoire, Géographie, Culture...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                      helperText: 'Choisissez ou créez une catégorie',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Veuillez entrer une catégorie';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      _categoryController.text = value;
                    },
                  );
                },
                onSelected: (category) {
                  _categoryController.text = category;
                },
              ),
              const SizedBox(height: 20),

              // Sélection de la réponse
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Réponse correcte *',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<bool>(
                              title: const Text('VRAI'),
                              value: true,
                              groupValue: _answer,
                              onChanged: (value) {
                                setState(() => _answer = value!);
                              },
                              activeColor: Colors.green,
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<bool>(
                              title: const Text('FAUX'),
                              value: false,
                              groupValue: _answer,
                              onChanged: (value) {
                                setState(() => _answer = value!);
                              },
                              activeColor: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Aperçu de la question
              Card(
                color: Colors.grey[100],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Aperçu',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _questionController.text.isEmpty
                            ? 'Votre question apparaîtra ici...'
                            : _questionController.text,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Catégorie: ${_categoryController.text.isEmpty ? "Non spécifiée" : _categoryController.text}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _answer ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Réponse: ${_answer ? "VRAI" : "FAUX"}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Bouton: Ajouter
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _submitQuestion,
                icon: _isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : const Icon(Icons.add),
                label: Text(_isLoading ? 'Ajout en cours...' : 'Ajouter la question'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFa855f7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(20),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
