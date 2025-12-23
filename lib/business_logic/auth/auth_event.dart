import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Vérifier l'état d'authentification au démarrage
class AuthCheckRequested extends AuthEvent {}

/// Inscription
class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String displayName;
  final File? avatarFile; // ← AJOUTÉ ICI

  const SignUpRequested({
    required this.email,
    required this.password,
    required this.displayName,
    this.avatarFile, // ← AJOUTÉ ICI (optionnel)
  });

  @override
  List<Object?> get props => [email, password, displayName, avatarFile];
}

/// Connexion
class SignInRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

/// Déconnexion
class SignOutRequested extends AuthEvent {}

/// Mettre à jour l'avatar
class UpdateAvatarRequested extends AuthEvent {
  final File imageFile;

  const UpdateAvatarRequested(this.imageFile);

  @override
  List<Object> get props => [imageFile];
}

/// Mettre à jour les statistiques après un quiz
class UpdateQuizStatsRequested extends AuthEvent {
  final int score;
  final int total;

  const UpdateQuizStatsRequested({
    required this.score,
    required this.total,
  });

  @override
  List<Object> get props => [score, total];
}

/// Réinitialiser le mot de passe
class ResetPasswordRequested extends AuthEvent {
  final String email;

  const ResetPasswordRequested(this.email);

  @override
  List<Object> get props => [email];
}