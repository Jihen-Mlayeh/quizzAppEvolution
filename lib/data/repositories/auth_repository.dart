import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream de l'état d'authentification
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Utilisateur actuel
  User? get currentUser => _firebaseAuth.currentUser;

  /// Inscription avec email et mot de passe
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // Créer le compte Firebase Auth
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) return null;

      // Mettre à jour le nom d'affichage
      await user.updateDisplayName(displayName);

      // Créer le document utilisateur dans Firestore
      final userModel = UserModel(
        id: user.uid,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toFirestore());

      print('✅ Utilisateur créé avec succès: ${user.uid}');
      return userModel;
    } on FirebaseAuthException catch (e) {
      print('❌ Erreur inscription: ${e.code}');
      throw _handleAuthException(e);
    } catch (e) {
      print('❌ Erreur inscription: $e');
      throw Exception('Erreur lors de l\'inscription');
    }
  }

  /// Connexion avec email et mot de passe
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) return null;

      // Mettre à jour la date de dernière connexion
      await _firestore.collection('users').doc(user.uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });

      // Récupérer les données utilisateur
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        throw Exception('Données utilisateur introuvables');
      }

      print('✅ Connexion réussie: ${user.uid}');
      return UserModel.fromFirestore(userDoc);
    } on FirebaseAuthException catch (e) {
      print('❌ Erreur connexion: ${e.code}');
      throw _handleAuthException(e);
    } catch (e) {
      print('❌ Erreur connexion: $e');
      throw Exception('Erreur lors de la connexion');
    }
  }

  /// Déconnexion
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
      print('✅ Déconnexion réussie');
    } catch (e) {
      print('❌ Erreur déconnexion: $e');
      throw Exception('Erreur lors de la déconnexion');
    }
  }

  /// Récupérer les données utilisateur depuis Firestore
  Future<UserModel?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) return null;

      return UserModel.fromFirestore(doc);
    } catch (e) {
      print('❌ Erreur récupération utilisateur: $e');
      return null;
    }
  }

  /// Mettre à jour les données utilisateur
  Future<void> updateUserData(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.id)
          .update(user.toFirestore());

      print('✅ Données utilisateur mises à jour');
    } catch (e) {
      print('❌ Erreur mise à jour utilisateur: $e');
      throw Exception('Erreur lors de la mise à jour');
    }
  }

  /// Mettre à jour l'avatar
  Future<void> updateAvatar(String userId, String avatarUrl) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'avatarUrl': avatarUrl,
      });

      print('✅ Avatar mis à jour');
    } catch (e) {
      print('❌ Erreur mise à jour avatar: $e');
      throw Exception('Erreur lors de la mise à jour de l\'avatar');
    }
  }

  /// Mettre à jour les statistiques après un quiz
  Future<void> updateQuizStats({
    required String userId,
    required int score,
    required int total,
  }) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) return;

      final userData = UserModel.fromFirestore(userDoc);
      final newTotalQuizzes = userData.totalQuizzes + 1;
      final newTotalScore = userData.totalScore + score;
      final newBestScore = score > userData.bestScore ? score : userData.bestScore;

      await _firestore.collection('users').doc(userId).update({
        'totalQuizzes': newTotalQuizzes,
        'totalScore': newTotalScore,
        'bestScore': newBestScore,
      });

      print('✅ Statistiques mises à jour');
    } catch (e) {
      print('❌ Erreur mise à jour stats: $e');
    }
  }

  /// Réinitialiser le mot de passe
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      print('✅ Email de réinitialisation envoyé');
    } on FirebaseAuthException catch (e) {
      print('❌ Erreur réinitialisation: ${e.code}');
      throw _handleAuthException(e);
    }
  }

  /// Gérer les exceptions Firebase Auth
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Le mot de passe est trop faible';
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé';
      case 'user-not-found':
        return 'Aucun utilisateur trouvé avec cet email';
      case 'wrong-password':
        return 'Mot de passe incorrect';
      case 'invalid-email':
        return 'Email invalide';
      case 'user-disabled':
        return 'Ce compte a été désactivé';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessayez plus tard';
      default:
        return 'Une erreur est survenue: ${e.message}';
    }
  }
}