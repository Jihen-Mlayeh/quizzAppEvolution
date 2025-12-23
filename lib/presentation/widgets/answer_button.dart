import 'package:flutter/material.dart';

class AnswerButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isCorrect;
  final bool isSelected;
  final bool showResult;

  const AnswerButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.isCorrect = false,
    this.isSelected = false,
    this.showResult = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Détermine la couleur du bouton
    Color buttonColor;
    Color? shadowColor;

    if (showResult && isSelected) {
      // Si on montre le résultat ET que ce bouton a été sélectionné
      if (isCorrect) {
        buttonColor = const Color(0xFF22c55e); // VERT si correct
        shadowColor = Colors.green.withOpacity(0.5);
      } else {
        buttonColor = const Color(0xFFef4444); // ROUGE si incorrect
        shadowColor = Colors.red.withOpacity(0.5);
      }
    } else {
      // Couleur par défaut (avant de répondre)
      buttonColor = Colors.white.withOpacity(0.2);
      shadowColor = null;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: ElevatedButton(
        onPressed: showResult ? null : onPressed, // Désactive si résultat affiché
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: buttonColor, // Garde la couleur même quand désactivé
          disabledForegroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: showResult && isSelected
                  ? Colors.white.withOpacity(0.3)
                  : Colors.transparent,
              width: 2,
            ),
          ),
          elevation: showResult && isSelected ? 8 : 2,
          shadowColor: shadowColor,
        ),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 300),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icône apparaît seulement quand le résultat est affiché
              if (showResult && isSelected) ...[
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  size: 24,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
