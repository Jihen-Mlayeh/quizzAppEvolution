import 'package:flutter/material.dart';
import '../../data/models/question_model.dart';
import 'answer_button.dart';

class QuestionCard extends StatelessWidget {
  final QuestionModel question;
  final Function(bool) onAnswer;
  final bool showResult;
  final AnswerModel? lastAnswer;

  const QuestionCard({
    Key? key,
    required this.question,
    required this.onAnswer,
    required this.showResult,
    this.lastAnswer,
  }) : super(key: key);

  // Méthode pour construire l'image (gère local et réseau)
  Widget _buildImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      // Image depuis Internet
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
                  : null,
              color: Colors.white,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      );
    } else {
      // Image locale
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      );
    }
  }

  // Placeholder si l'image n'est pas trouvée
  Widget _buildPlaceholder() {
    return Container(
      color: Colors.purple.withOpacity(0.3),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, size: 48, color: Colors.white54),
            SizedBox(height: 8),
            Text(
              'Image non disponible',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Category Badge
          Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFec4899), Color(0xFFa855f7)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFa855f7).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.category, size: 16, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      question.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Image Container avec gestion d'erreur
          Container(
            height: 200,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white.withOpacity(0.05),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _buildImage(question.imageUrl),
            ),
          ),

          // Question Text
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              question.question,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Answer Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: AnswerButton(
                    label: 'VRAI',
                    onPressed: () => onAnswer(true),
                    isCorrect: lastAnswer?.isCorrect ?? false,
                    isSelected: lastAnswer?.userAnswer == true,
                    showResult: showResult,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: AnswerButton(
                    label: 'FAUX',
                    onPressed: () => onAnswer(false),
                    isCorrect: lastAnswer?.isCorrect ?? false,
                    isSelected: lastAnswer?.userAnswer == false,
                    showResult: showResult,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
