import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;
  final int totalQuizzes;
  final int totalScore;
  final int bestScore;
  final DateTime createdAt;
  final DateTime? lastLogin;

  const UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
    this.totalQuizzes = 0,
    this.totalScore = 0,
    this.bestScore = 0,
    required this.createdAt,
    this.lastLogin,
  });

  // Convertir en Map pour Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'totalQuizzes': totalQuizzes,
      'totalScore': totalScore,
      'bestScore': bestScore,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
    };
  }

  // Créer depuis Firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      avatarUrl: data['avatarUrl'],
      totalQuizzes: data['totalQuizzes'] ?? 0,
      totalScore: data['totalScore'] ?? 0,
      bestScore: data['bestScore'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastLogin: data['lastLogin'] != null
          ? (data['lastLogin'] as Timestamp).toDate()
          : null,
    );
  }

  // Copie avec modifications
  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? avatarUrl,
    int? totalQuizzes,
    int? totalScore,
    int? bestScore,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      totalQuizzes: totalQuizzes ?? this.totalQuizzes,
      totalScore: totalScore ?? this.totalScore,
      bestScore: bestScore ?? this.bestScore,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}