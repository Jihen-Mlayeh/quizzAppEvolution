import 'package:equatable/equatable.dart';
import '../../../data/models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// État initial
class AuthInitial extends AuthState {}

/// Chargement
class AuthLoading extends AuthState {}

/// Authentifié
class Authenticated extends AuthState {
  final UserModel user;

  const Authenticated(this.user);

  @override
  List<Object> get props => [user];
}

/// Non authentifié
class Unauthenticated extends AuthState {}

/// Erreur
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

/// Avatar en cours de mise à jour
class AvatarUpdating extends AuthState {}

/// Avatar mis à jour
class AvatarUpdated extends AuthState {
  final UserModel user;

  const AvatarUpdated(this.user);

  @override
  List<Object> get props => [user];
}

/// Mot de passe réinitialisé
class PasswordResetSent extends AuthState {
  final String email;

  const PasswordResetSent(this.email);

  @override
  List<Object> get props => [email];
}