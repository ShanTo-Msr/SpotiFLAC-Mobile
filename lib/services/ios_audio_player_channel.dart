import 'package:flutter/services.dart';

/// Platform channel for iOS internal player and EQ control
class IOSAudioPlayerChannel {
  static const platform =
      MethodChannel('com.spotififlac/ios_audio_player');

  /// Initialize the internal iOS player
  static Future<void> initializePlayer() async {
    try {
      await platform.invokeMethod('initializePlayer');
    } on PlatformException catch (e) {
      print('Error initializing player: ${e.message}');
      rethrow;
    }
  }

  /// Play audio file at the given path
  static Future<void> playAudio(String filePath) async {
    try {
      await platform.invokeMethod('playAudio', {'filePath': filePath});
    } on PlatformException catch (e) {
      print('Error playing audio: ${e.message}');
      rethrow;
    }
  }

  /// Stop playback
  static Future<void> stop() async {
    try {
      await platform.invokeMethod('stop');
    } on PlatformException catch (e) {
      print('Error stopping playback: ${e.message}');
      rethrow;
    }
  }

  /// Pause playback
  static Future<void> pause() async {
    try {
      await platform.invokeMethod('pause');
    } on PlatformException catch (e) {
      print('Error pausing playback: ${e.message}');
      rethrow;
    }
  }

  /// Resume playback
  static Future<void> resume() async {
    try {
      await platform.invokeMethod('resume');
    } on PlatformException catch (e) {
      print('Error resuming playback: ${e.message}');
      rethrow;
    }
  }

  /// Set EQ band gain
  /// [bandIndex]: 0-9 for 10-band EQ
  /// [gain]: -12.0 to 12.0 dB
  static Future<void> setEQBandGain(int bandIndex, double gain) async {
    try {
      await platform.invokeMethod('setEQBandGain', {
        'bandIndex': bandIndex,
        'gain': gain,
      });
    } on PlatformException catch (e) {
      print('Error setting EQ band gain: ${e.message}');
      rethrow;
    }
  }

  /// Set EQ preamp gain (master volume adjustment)
  /// [gain]: -6.0 to 6.0 dB
  static Future<void> setEQPreamp(double gain) async {
    try {
      await platform.invokeMethod('setEQPreamp', {'gain': gain});
    } on PlatformException catch (e) {
      print('Error setting EQ preamp: ${e.message}');
      rethrow;
    }
  }

  /// Enable/disable EQ
  static Future<void> setEQEnabled(bool enabled) async {
    try {
      await platform.invokeMethod('setEQEnabled', {'enabled': enabled});
    } on PlatformException catch (e) {
      print('Error setting EQ enabled state: ${e.message}');
      rethrow;
    }
  }

  /// Reset all EQ bands to 0 dB
  static Future<void> resetEQ() async {
    try {
      await platform.invokeMethod('resetEQ');
    } on PlatformException catch (e) {
      print('Error resetting EQ: ${e.message}');
      rethrow;
    }
  }

  /// Apply all EQ settings at once
  /// [gains]: List of 10 gain values (-12.0 to 12.0 dB)
  /// [preamp]: Preamp gain (-6.0 to 6.0 dB)
  /// [enabled]: Whether EQ is enabled
  static Future<void> applyEQSettings({
    required List<double> gains,
    required double preamp,
    required bool enabled,
  }) async {
    try {
      await platform.invokeMethod('applyEQSettings', {
        'gains': gains,
        'preamp': preamp,
        'enabled': enabled,
      });
    } on PlatformException catch (e) {
      print('Error applying EQ settings: ${e.message}');
      rethrow;
    }
  }
}
