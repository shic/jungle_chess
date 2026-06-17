// Lightweight sound-effect wrapper that keeps audio failures from interrupting gameplay.

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

enum GameSoundEffect { tap, move, capture }

class GameAudioService {
  GameAudioService._();

  static final GameAudioService instance = GameAudioService._();

  final Map<GameSoundEffect, AudioPlayer> _players = {};
  bool _enabled = true;

  bool get enabled => _enabled;

  set enabled(bool value) {
    _enabled = value;
    if (!value) {
      unawaited(_stopAll());
    }
  }

  void play(GameSoundEffect effect) {
    if (!_enabled) {
      return;
    }
    unawaited(_play(effect));
  }

  Future<void> _play(GameSoundEffect effect) async {
    try {
      final player = _players.putIfAbsent(effect, () {
        return AudioPlayer(playerId: 'jungle_chess_${effect.name}')
          ..setReleaseMode(ReleaseMode.stop)
          ..setPlayerMode(PlayerMode.lowLatency);
      });

      await player.stop();
      await player.play(AssetSource(_assetPath(effect)));
    } catch (error) {
      debugPrint('Game sound failed: $error');
    }
  }

  Future<void> _stopAll() async {
    try {
      await Future.wait(_players.values.map((player) => player.stop()));
    } catch (error) {
      debugPrint('Game sound stop failed: $error');
    }
  }

  String _assetPath(GameSoundEffect effect) {
    return switch (effect) {
      GameSoundEffect.tap => 'sounds/tap.wav',
      GameSoundEffect.move => 'sounds/move.wav',
      GameSoundEffect.capture => 'sounds/capture.wav',
    };
  }
}
