import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();

  // Sons (URLs publiques qui fonctionnent sur web)
  static const String _victorySound = 'https://www.soundjay.com/misc/sounds/bell-ringing-05.mp3';
  static const String _defeatSound = 'https://www.soundjay.com/button/sounds/button-09.mp3';

  Future<void> playVictory() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(_victorySound));
      print('🎵 Son victoire');
    } catch (e) {
      print('❌ Erreur son: $e');
    }
  }

  Future<void> playDefeat() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(_defeatSound));
      print('🎵 Son défaite');
    } catch (e) {
      print('❌ Erreur son: $e');
    }
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
  }
}