import '../models/question_model.dart';

class QuizRepository {
  List<QuestionModel> getQuestions() {
    return [
      // QUESTIONS VRAIES
      QuestionModel(
        id: 1,
        question: "La France a dû céder l'Alsace et la Moselle à l'Allemagne après la guerre de 1870-1871.",
        imageUrl: "assets/images/alsace.jpg",
        answer: true,
        category: "Histoire",
      ),
      QuestionModel(
        id: 2,
        question: "La Tour Eiffel a été construite en 1889 pour l'Exposition Universelle de Paris.",
        imageUrl: "assets/images/tour_eiffel.jpg",
        answer: true,
        category: "Culture",
      ),
      QuestionModel(
        id: 3,
        question: "La Révolution française a commencé en 1789.",
        imageUrl: "assets/images/revolution.jpg",
        answer: true,
        category: "Histoire",
      ),
      QuestionModel(
        id: 4,
        question: "Le Mont Blanc est le plus haut sommet d'Europe.",
        imageUrl: "assets/images/mont_blanc.jpg",
        answer: true,
        category: "Géographie",
      ),
      QuestionModel(
        id: 5,
        question: "La France compte 13 régions en métropole.",
        imageUrl: "assets/images/regions.jpg",
        answer: true,
        category: "Géographie",
      ),
      QuestionModel(
        id: 6,
        question: "Victor Hugo a écrit 'Les Misérables'.",
        imageUrl: "assets/images/victor_hug.jpg",
        answer: true,
        category: "Culture",
      ),
      QuestionModel(
        id: 7,
        question: "Le français est la langue officielle de la France.",
        imageUrl: "assets/images/langue.jpg",
        answer: true,
        category: "Culture",
      ),

      // QUESTIONS FAUSSES
      QuestionModel(
        id: 8,
        question: "Paris est traversée par le fleuve Loire.",
        imageUrl: "assets/images/paris_seine.jpg",
        answer: false,
        category: "Géographie",
      ),
      QuestionModel(
        id: 9,
        question: "Napoléon Bonaparte est né en France continentale.",
        imageUrl: "assets/images/napoleon.jpg",
        answer: false, // Il est né en Corse
        category: "Histoire",
      ),
      QuestionModel(
        id: 10,
        question: "La France a 8 pays frontaliers.",
        imageUrl: "assets/images/frontieres.jpg",
        answer: false, // Elle en a 11 (incluant les territoires d'outre-mer)
        category: "Géographie",
      ),
      QuestionModel(
        id: 11,
        question: "Le Louvre est le musée le plus visité au monde.",
        imageUrl: "assets/images/louvre.jpg",
        answer: true,
        category: "Culture",
      ),
      QuestionModel(
        id: 12,
        question: "La Marseillaise a été écrite pendant la Révolution de 1848.",
        imageUrl: "assets/images/marseillaise.jpg",
        answer: false, // Elle a été écrite en 1792
        category: "Histoire",
      ),
      QuestionModel(
        id: 13,
        question: "Strasbourg est la capitale de l'Alsace.",
        imageUrl: "assets/images/strasbourg.jpg",
        answer: true,
        category: "Géographie",
      ),
      QuestionModel(
        id: 14,
        question: "La France a remporté la Coupe du Monde de football 3 fois.",
        imageUrl: "assets/images/football.jpg",
        answer: false, // 2 fois : 1998 et 2018
        category: "Sport",
      ),
      QuestionModel(
        id: 15,
        question: "Molière est l'auteur de 'Le Tartuffe'.",
        imageUrl: "assets/images/moliere.jpg",
        answer: true,
        category: "Culture",
      ),
    ];
  }

  // Méthode pour obtenir des questions aléatoires
  List<QuestionModel> getRandomQuestions(int count) {
    final allQuestions = getQuestions();
    allQuestions.shuffle();
    return allQuestions.take(count).toList();
  }

  // Méthode pour obtenir des questions par catégorie
  List<QuestionModel> getQuestionsByCategory(String category) {
    return getQuestions()
        .where((q) => q.category == category)
        .toList();
  }

  // Obtenir toutes les catégories disponibles
  List<String> getCategories() {
    return getQuestions()
        .map((q) => q.category)
        .toSet()
        .toList();
  }
}