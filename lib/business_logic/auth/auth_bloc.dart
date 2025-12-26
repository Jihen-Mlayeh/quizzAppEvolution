import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/storage_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final StorageRepository storageRepository;

  AuthBloc({
    required this.authRepository,
    required this.storageRepository,
  }) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<SignInRequested>(_onSignInRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<UpdateAvatarRequested>(_onUpdateAvatarRequested);
    on<UpdateQuizStatsRequested>(_onUpdateQuizStatsRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
  }

  /// Vérifier l'état d'authentification
  Future<void> _onAuthCheckRequested(
      AuthCheckRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());

    final currentUser = authRepository.currentUser;

    if (currentUser == null) {
      emit(Unauthenticated());
      return;
    }

    try {
      final userData = await authRepository.getUserData(currentUser.uid);

      if (userData != null) {
        emit(Authenticated(userData));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      print('❌ Erreur auth check: $e');
      emit(Unauthenticated());
    }
  }

  /// Inscription - VERSION OPTIMISÉE (avatar en arrière-plan)
  Future<void> _onSignUpRequested(
      SignUpRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());

    try {
      print('📝 Début inscription pour: ${event.email}');

      // 1. Créer le compte utilisateur RAPIDEMENT
      final user = await authRepository.signUp(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
      );

      if (user == null) {
        emit(const AuthError('Erreur lors de l\'inscription'));
        return;
      }

      print('✅ Compte créé avec succès: ${user.id}');

      // 2. Émettre immédiatement Authenticated (l'utilisateur peut continuer)
      emit(Authenticated(user));

      // 3. Upload de l'avatar EN ARRIÈRE-PLAN (si présent)
      final hasAvatar = (kIsWeb && event.avatarBytes != null) || event.avatarFile != null;

      if (hasAvatar) {
        print('🔄 Upload avatar en arrière-plan...');
        _uploadAvatarInBackground(user.id, event.avatarFile, event.avatarBytes);
      } else {
        print('✅ Inscription complète sans avatar');
      }
    } catch (e) {
      print('❌ Erreur inscription: $e');
      emit(AuthError(e.toString()));
    }
  }

  /// Upload avatar en arrière-plan (ne bloque pas l'inscription)
  Future<void> _uploadAvatarInBackground(
      String userId,
      dynamic avatarFile,
      dynamic avatarBytes,
      ) async {
    try {
      String? avatarUrl;

      if (kIsWeb && avatarBytes != null) {
        print('🌐 Upload avatar sur Web (arrière-plan)...');
        avatarUrl = await storageRepository.uploadAvatarFromBytes(
          userId: userId,
          imageBytes: avatarBytes,
        );
      } else if (avatarFile != null) {
        print('📱 Upload avatar sur Mobile (arrière-plan)...');
        avatarUrl = await storageRepository.uploadAvatar(
          userId: userId,
          imageFile: avatarFile,
        );
      }

      if (avatarUrl != null) {
        print('✅ Avatar uploadé: $avatarUrl');
        await authRepository.updateAvatar(userId, avatarUrl);

        // Rafraîchir les données utilisateur
        final updatedUser = await authRepository.getUserData(userId);
        if (updatedUser != null) {
          emit(Authenticated(updatedUser));
          print('✅ Avatar mis à jour dans le profil');
        }
      } else {
        print('⚠️ Upload avatar échoué (non bloquant)');
      }
    } catch (e) {
      print('⚠️ Erreur upload avatar (non bloquant): $e');
      // Ne pas émettre d'erreur car le compte est déjà créé
    }
  }

  /// Connexion
  Future<void> _onSignInRequested(
      SignInRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());

    try {
      print('🔐 Tentative de connexion pour: ${event.email}');

      final user = await authRepository.signIn(
        email: event.email,
        password: event.password,
      );

      if (user != null) {
        print('✅ Connexion réussie');
        emit(Authenticated(user));
      } else {
        print('❌ Connexion échouée');
        emit(const AuthError('Email ou mot de passe incorrect'));
      }
    } catch (e) {
      print('❌ Erreur connexion: $e');

      // Messages d'erreur plus clairs
      String errorMessage = 'Erreur lors de la connexion';
      if (e.toString().contains('user-not-found')) {
        errorMessage = 'Aucun compte trouvé avec cet email';
      } else if (e.toString().contains('wrong-password')) {
        errorMessage = 'Mot de passe incorrect';
      } else if (e.toString().contains('invalid-email')) {
        errorMessage = 'Format d\'email invalide';
      } else if (e.toString().contains('too-many-requests')) {
        errorMessage = 'Trop de tentatives. Réessayez plus tard';
      }

      emit(AuthError(errorMessage));
    }
  }

  /// Déconnexion
  Future<void> _onSignOutRequested(
      SignOutRequested event,
      Emitter<AuthState> emit,
      ) async {
    try {
      print('👋 Déconnexion en cours...');
      await authRepository.signOut();
      print('✅ Déconnexion réussie');
      emit(Unauthenticated());
    } catch (e) {
      print('❌ Erreur déconnexion: $e');
      emit(AuthError(e.toString()));
    }
  }

  /// Mettre à jour l'avatar
  Future<void> _onUpdateAvatarRequested(
      UpdateAvatarRequested event,
      Emitter<AuthState> emit,
      ) async {
    if (state is! Authenticated) {
      print('❌ Impossible de mettre à jour l\'avatar: utilisateur non authentifié');
      return;
    }

    final currentUser = (state as Authenticated).user;
    emit(AvatarUpdating());

    try {
      print('🔄 Mise à jour avatar pour: ${currentUser.id}');

      // Upload de l'image selon la plateforme
      String? avatarUrl;

      if (kIsWeb && event.imageBytes != null) {
        print('🌐 Upload avatar sur Web...');
        avatarUrl = await storageRepository.uploadAvatarFromBytes(
          userId: currentUser.id,
          imageBytes: event.imageBytes!,
        );
      } else if (event.imageFile != null) {
        print('📱 Upload avatar sur Mobile...');
        avatarUrl = await storageRepository.uploadAvatar(
          userId: currentUser.id,
          imageFile: event.imageFile!,
        );
      }

      if (avatarUrl == null) {
        print('❌ Erreur lors de l\'upload de l\'avatar');
        emit(const AuthError('Erreur lors de l\'upload de l\'avatar'));
        emit(Authenticated(currentUser));
        return;
      }

      // Mise à jour dans Firestore
      print('💾 Mise à jour Firestore...');
      await authRepository.updateAvatar(currentUser.id, avatarUrl);

      // Récupérer les données mises à jour
      final updatedUser = currentUser.copyWith(avatarUrl: avatarUrl);

      print('✅ Avatar mis à jour avec succès');
      emit(AvatarUpdated(updatedUser));
      emit(Authenticated(updatedUser));
    } catch (e) {
      print('❌ Erreur update avatar: $e');
      emit(AuthError(e.toString()));
      emit(Authenticated(currentUser));
    }
  }

  /// Mettre à jour les statistiques
  Future<void> _onUpdateQuizStatsRequested(
      UpdateQuizStatsRequested event,
      Emitter<AuthState> emit,
      ) async {
    if (state is! Authenticated) {
      print('❌ Impossible de mettre à jour les stats: utilisateur non authentifié');
      return;
    }

    final currentUser = (state as Authenticated).user;

    try {
      print('📊 Mise à jour statistiques: score=${event.score}, total=${event.total}');

      await authRepository.updateQuizStats(
        userId: currentUser.id,
        score: event.score,
        total: event.total,
      );

      // Récupérer les données mises à jour
      final updatedUser = await authRepository.getUserData(currentUser.id);

      if (updatedUser != null) {
        print('✅ Statistiques mises à jour');
        emit(Authenticated(updatedUser));
      }
    } catch (e) {
      print('❌ Erreur mise à jour stats: $e');
    }
  }

  /// Réinitialiser le mot de passe
  Future<void> _onResetPasswordRequested(
      ResetPasswordRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());

    try {
      print('📧 Envoi email de réinitialisation à: ${event.email}');
      await authRepository.resetPassword(event.email);
      print('✅ Email envoyé avec succès');
      emit(PasswordResetSent(event.email));

      // Attendre un peu avant de revenir à Unauthenticated
      await Future.delayed(const Duration(seconds: 2));
      emit(Unauthenticated());
    } catch (e) {
      print('❌ Erreur reset password: $e');

      String errorMessage = 'Erreur lors de l\'envoi de l\'email';
      if (e.toString().contains('user-not-found')) {
        errorMessage = 'Aucun compte trouvé avec cet email';
      } else if (e.toString().contains('invalid-email')) {
        errorMessage = 'Format d\'email invalide';
      }

      emit(AuthError(errorMessage));
      emit(Unauthenticated());
    }
  }
}