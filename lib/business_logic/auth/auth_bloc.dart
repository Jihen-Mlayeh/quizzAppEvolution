import 'package:flutter_bloc/flutter_bloc.dart';
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
    // ❌ SUPPRIMÉ - Cause des boucles infinies
    // authRepository.authStateChanges.listen((firebaseUser) {
    //   if (firebaseUser != null) {
    //     add(AuthCheckRequested());
    //   } else {
    //     emit(Unauthenticated());
    //   }
    // });

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

  /// Inscription
  Future<void> _onSignUpRequested(
      SignUpRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());

    try {
      // 1. Créer le compte utilisateur
      final user = await authRepository.signUp(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
      );

      if (user == null) {
        emit(const AuthError('Erreur lors de l\'inscription'));
        return;
      }

      // 2. Si une image a été sélectionnée, l'uploader
      if (event.avatarFile != null) {
        final avatarUrl = await storageRepository.uploadAvatar(
          userId: user.id,
          imageFile: event.avatarFile!,
        );

        if (avatarUrl != null) {
          // 3. Mettre à jour l'avatar dans Firestore
          await authRepository.updateAvatar(user.id, avatarUrl);

          // 4. Récupérer les données mises à jour
          final updatedUser = user.copyWith(avatarUrl: avatarUrl);
          emit(Authenticated(updatedUser));
        } else {
          // L'upload a échoué, mais le compte est créé
          emit(Authenticated(user));
        }
      } else {
        // Pas d'avatar sélectionné
        emit(Authenticated(user));
      }
    } catch (e) {
      print('❌ Erreur inscription: $e');
      emit(AuthError(e.toString()));
    }
  }

  /// Connexion
  Future<void> _onSignInRequested(
      SignInRequested event,
      Emitter<AuthState> emit,
      ) async {
    emit(AuthLoading());

    try {
      final user = await authRepository.signIn(
        email: event.email,
        password: event.password,
      );

      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(const AuthError('Erreur lors de la connexion'));
      }
    } catch (e) {
      print('❌ Erreur connexion: $e');
      emit(AuthError(e.toString()));
    }
  }

  /// Déconnexion
  Future<void> _onSignOutRequested(
      SignOutRequested event,
      Emitter<AuthState> emit,
      ) async {
    try {
      await authRepository.signOut();
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
    if (state is! Authenticated) return;

    final currentUser = (state as Authenticated).user;
    emit(AvatarUpdating());

    try {
      // Upload de l'image
      final avatarUrl = await storageRepository.uploadAvatar(
        userId: currentUser.id,
        imageFile: event.imageFile,
      );

      if (avatarUrl == null) {
        emit(const AuthError('Erreur lors de l\'upload de l\'avatar'));
        emit(Authenticated(currentUser));
        return;
      }

      // Mise à jour dans Firestore
      await authRepository.updateAvatar(currentUser.id, avatarUrl);

      // Récupérer les données mises à jour
      final updatedUser = currentUser.copyWith(avatarUrl: avatarUrl);

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
    if (state is! Authenticated) return;

    final currentUser = (state as Authenticated).user;

    try {
      await authRepository.updateQuizStats(
        userId: currentUser.id,
        score: event.score,
        total: event.total,
      );

      // Récupérer les données mises à jour
      final updatedUser = await authRepository.getUserData(currentUser.id);

      if (updatedUser != null) {
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
      await authRepository.resetPassword(event.email);
      emit(PasswordResetSent(event.email));
      emit(Unauthenticated());
    } catch (e) {
      print('❌ Erreur reset password: $e');
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }
}