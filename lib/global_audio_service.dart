import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
class GlobalAudioService {
  static final GlobalAudioService _instance = GlobalAudioService._internal();
  factory GlobalAudioService() {
    return _instance;
  }
  GlobalAudioService._internal() {
    _audioPlayer.playerStateStream.listen((state) {
      isPlayingNotifier.value = state.playing && state.processingState != ProcessingState.completed;
      if (state.processingState == ProcessingState.completed && _audioPlayer.loopMode != LoopMode.one) {
        _audioPlayer.seek(Duration.zero);
        _audioPlayer.pause();
      }
    });
    _audioPlayer.positionStream.listen((position) {
      positionNotifier.value = position;
    });
    _audioPlayer.durationStream.listen((duration) {
      durationNotifier.value = duration ?? Duration.zero;
    });
  }
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ValueNotifier<Map<String, dynamic>?> currentItemNotifier = ValueNotifier(null);
  final ValueNotifier<bool> isPlayingNotifier = ValueNotifier(false);
  final ValueNotifier<Duration> positionNotifier = ValueNotifier(Duration.zero);
  final ValueNotifier<Duration> durationNotifier = ValueNotifier(Duration.zero);
  AudioPlayer get player => _audioPlayer;
  Future<void> playItem(Map<String, dynamic> item) async {
    final newAudioUrl = item['audio_url']?.toString();
    final currentAudioUrl = currentItemNotifier.value?['audio_url']?.toString();
    if (newAudioUrl == null || newAudioUrl.isEmpty) {
      return;
    }
    if (newAudioUrl == currentAudioUrl) {
      if (_audioPlayer.playing) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play();
      }
      return;
    }
    currentItemNotifier.value = item;
    try {
      await _audioPlayer.setUrl(newAudioUrl);
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('GlobalAudioService Error: $e');
    }
  }
  Future<void> togglePlayPause() async {
    if (_audioPlayer.playing) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }
  Future<void> stopAndDismiss() async {
    await _audioPlayer.stop();
    currentItemNotifier.value = null;
  }
  void dispose() {
    _audioPlayer.dispose();
    currentItemNotifier.dispose();
    isPlayingNotifier.dispose();
    positionNotifier.dispose();
    durationNotifier.dispose();
  }
}
