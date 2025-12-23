import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../business_logic/auth/auth_bloc.dart';
import '../../../business_logic/auth/auth_event.dart';
import '../../../business_logic/auth/auth_state.dart';
import '../../../data/repositories/storage_repository.dart';
import '../../animations/animated_background.dart';
import '../../themes/app_theme.dart';
import 'login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  Future<void> _showAvatarOptions(BuildContext context) async {
    final storageRepository = StorageRepository();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2d1b4e),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choisir une photo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFFa855f7)),
              title: const Text(
                'Galerie',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () async {
                Navigator.pop(context);
                final imageFile = await storageRepository.pickImageFromGallery();
                if (imageFile != null && context.mounted) {
                  context.read<AuthBloc>().add(UpdateAvatarRequested(imageFile));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFFa855f7)),
              title: const Text(
                'Caméra',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () async {
                Navigator.pop(context);
                final imageFile = await storageRepository.takePhoto();
                if (imageFile != null && context.mounted) {
                  context.read<AuthBloc>().add(UpdateAvatarRequested(imageFile));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AnimatedBackground(),
          SafeArea(
            child: BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is Unauthenticated) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                        (route) => false,
                  );
                } else if (state is AuthError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else if (state is AvatarUpdated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Avatar mis à jour avec succès !'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is! Authenticated && state is! AvatarUpdating) {
                  return const Center(child: CircularProgressIndicator());
                }

                final user = state is Authenticated
                    ? state.user
                    : state is AvatarUpdating
                    ? (context.read<AuthBloc>().state as Authenticated).user
                    : null;

                if (user == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                final isUpdating = state is AvatarUpdating;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Header
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: const Color(0xFF2d1b4e),
                                  title: const Text(
                                    'Déconnexion',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  content: const Text(
                                    'Voulez-vous vraiment vous déconnecter ?',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Annuler'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        context
                                            .read<AuthBloc>()
                                            .add(SignOutRequested());
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: const Text('Déconnexion'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: const Icon(Icons.logout, color: Colors.red),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Avatar
                      Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppTheme.primaryGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFa855f7).withOpacity(0.5),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(4),
                            child: CircleAvatar(
                              radius: 70,
                              backgroundColor: const Color(0xFF2d1b4e),
                              backgroundImage: user.avatarUrl != null
                                  ? CachedNetworkImageProvider(user.avatarUrl!)
                                  : null,
                              child: user.avatarUrl == null
                                  ? Text(
                                user.displayName[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                                  : null,
                            ),
                          ),
                          if (isUpdating)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withOpacity(0.5),
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => _showAvatarOptions(context),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: AppTheme.primaryGradient,
                                  border: Border.all(
                                    color: const Color(0xFF1a0b2e),
                                    width: 3,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Nom
                      Text(
                        user.displayName,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Email
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Statistiques
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Statistiques',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _StatCard(
                                  icon: Icons.quiz,
                                  value: user.totalQuizzes.toString(),
                                  label: 'Quiz',
                                ),
                                _StatCard(
                                  icon: Icons.star,
                                  value: user.bestScore.toString(),
                                  label: 'Meilleur',
                                ),
                                _StatCard(
                                  icon: Icons.emoji_events,
                                  value: user.totalQuizzes > 0
                                      ? ((user.totalScore / user.totalQuizzes)
                                      .toStringAsFixed(1))
                                      : '0',
                                  label: 'Moyenne',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Informations du compte
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Informations du compte',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _InfoRow(
                              icon: Icons.calendar_today,
                              label: 'Membre depuis',
                              value: _formatDate(user.createdAt),
                            ),
                            const SizedBox(height: 12),
                            _InfoRow(
                              icon: Icons.access_time,
                              label: 'Dernière connexion',
                              value: user.lastLogin != null
                                  ? _formatDate(user.lastLogin!)
                                  : 'Jamais',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Bouton Modifier le profil (désactivé pour l'instant)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Fonctionnalité bientôt disponible'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Modifier le profil'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(
                              color: Color(0xFFa855f7),
                              width: 2,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Aujourd\'hui';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jours';
    } else if (difference.inDays < 30) {
      return 'Il y a ${(difference.inDays / 7).floor()} semaines';
    } else if (difference.inDays < 365) {
      return 'Il y a ${(difference.inDays / 30).floor()} mois';
    } else {
      return 'Il y a ${(difference.inDays / 365).floor()} ans';
    }
  }
}

// Widget pour les cartes de statistiques
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppTheme.primaryGradient,
          ),
          child: Icon(icon, color: Colors.white, size: 32),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

// Widget pour les lignes d'information
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFa855f7), size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}