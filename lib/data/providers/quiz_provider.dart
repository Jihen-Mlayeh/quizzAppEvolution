import 'package:flutter/foundation.dart';
import '../models/question_model.dart';
import '../repositories/quiz_repository.dart';

class QuizProvider with ChangeNotifier {
  final QuizRepository _repository;

  // State variables
  List<QuestionModel> _questions = [];
  int _currentQuestionIndex = 0;
  int _score = 0;
  List<AnswerModel> _answers = [];
  bool _showResult = false;
  bool _isCompleted = false;
  bool _isLoading = false;

  // Constructor
  QuizProvider({required QuizRepository repository}) : _repository = repository {
    loadQuestions();
  }

  // Getters - exposent l'état de manière immutable
  List<QuestionModel> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  int get score => _score;
  List<AnswerModel> get answers => _answers;
  bool get showResult => _showResult;
  bool get isCompleted => _isCompleted;
  bool get isLoading => _isLoading;

  QuestionModel? get currentQuestion {
    if (_questions.isEmpty || _currentQuestionIndex >= _questions.length) {
      return null;
    }
    return _questions[_currentQuestionIndex];
  }

  AnswerModel? get lastAnswer {
    if (_answers.isEmpty) return null;
    return _answers.last;
  }

  int get totalQuestions => _questions.length;

  double get progressPercentage {
    if (_questions.isEmpty) return 0.0;
    return (_currentQuestionIndex + 1) / _questions.length;
  }

  // ============================================
  // METHODS - Gestion de la logique métier
  // ============================================

  /// Charge les questions depuis le repository
  Future<void> loadQuestions() async {
    _isLoading = true;
    notifyListeners(); // Notifie les widgets écouteurs

    // Simule un délai de chargement (comme si on fetch depuis API)
    await Future.delayed(const Duration(milliseconds: 500));

    _questions = _repository.getQuestions();
    _isLoading = false;
    notifyListeners();
  }

  /// Enregistre la réponse de l'utilisateur
  Future<void> answerQuestion(bool userAnswer) async {
    if (currentQuestion == null || _showResult) return;

    // Vérifie si la réponse est correcte
    final isCorrect = userAnswer == currentQuestion!.answer;

    // Crée un nouvel objet AnswerModel
    final newAnswer = AnswerModel(
      questionId: currentQuestion!.id,
      userAnswer: userAnswer,
      isCorrect: isCorrect,
    );

    // Met à jour l'état
    _answers.add(newAnswer);
    if (isCorrect) {
      _score++;
    }
    _showResult = true;
    notifyListeners();

    // Attend 1.5 secondes puis passe à la question suivante
    await Future.delayed(const Duration(milliseconds: 1500));
    nextQuestion();
  }

  /// Passe à la question suivante
  void nextQuestion() {
    _showResult = false;

    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    } else {
      // Quiz terminé
      _isCompleted = true;
      notifyListeners();
    }
  }

  /// Réinitialise le quiz
  void resetQuiz() {
    _currentQuestionIndex = 0;
    _score = 0;
    _answers = [];
    _showResult = false;
    _isCompleted = false;
    notifyListeners();
  }

  /// Nettoie les ressources (bonne pratique)
  @override
  void dispose() {
    super.dispose();
  }
}