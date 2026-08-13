import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// EQ Band model
class EQBand {
  final String name;
  final double frequency; // Hz
  double gain; // dB

  EQBand({
    required this.name,
    required this.frequency,
    this.gain = 0.0,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'frequency': frequency,
    'gain': gain,
  };

  factory EQBand.fromJson(Map<String, dynamic> json) => EQBand(
    name: json['name'],
    frequency: json['frequency'],
    gain: json['gain'] ?? 0.0,
  );
}

// EQ Preset model
class EQPreset {
  final String name;
  final List<double> gains; // Gains for each band
  final double preamp; // Global gain adjustment

  EQPreset({
    required this.name,
    required this.gains,
    this.preamp = 0.0,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'gains': gains,
    'preamp': preamp,
  };

  factory EQPreset.fromJson(Map<String, dynamic> json) => EQPreset(
    name: json['name'],
    gains: List<double>.from(json['gains']),
    preamp: json['preamp'] ?? 0.0,
  );
}

// EQ Settings model
class EQSettings {
  final List<EQBand> bands;
  final double preamp;
  final String activePreset; // Name of the active preset
  final bool enabled;

  EQSettings({
    required this.bands,
    this.preamp = 0.0,
    this.activePreset = 'Flat',
    this.enabled = true,
  });

  EQSettings copyWith({
    List<EQBand>? bands,
    double? preamp,
    String? activePreset,
    bool? enabled,
  }) => EQSettings(
    bands: bands ?? this.bands,
    preamp: preamp ?? this.preamp,
    activePreset: activePreset ?? this.activePreset,
    enabled: enabled ?? this.enabled,
  );

  Map<String, dynamic> toJson() => {
    'bands': bands.map((b) => b.toJson()).toList(),
    'preamp': preamp,
    'activePreset': activePreset,
    'enabled': enabled,
  };

  factory EQSettings.fromJson(Map<String, dynamic> json) => EQSettings(
    bands: (json['bands'] as List)
        .map((b) => EQBand.fromJson(b))
        .toList(),
    preamp: json['preamp'] ?? 0.0,
    activePreset: json['activePreset'] ?? 'Flat',
    enabled: json['enabled'] ?? true,
  );
}

// Default 10-band EQ configuration
class EQDefaults {
  static const List<String> bandNames = [
    '31 Hz',
    '62 Hz',
    '125 Hz',
    '250 Hz',
    '500 Hz',
    '1 kHz',
    '2 kHz',
    '4 kHz',
    '8 kHz',
    '16 kHz',
  ];

  static const List<double> bandFrequencies = [
    31,
    62,
    125,
    250,
    500,
    1000,
    2000,
    4000,
    8000,
    16000,
  ];

  // Preset definitions
  static final Map<String, EQPreset> presets = {
    'Flat': EQPreset(
      name: 'Flat',
      gains: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      preamp: 0,
    ),
    'Rock': EQPreset(
      name: 'Rock',
      gains: [3, 2, -1, -2, 0, 2, 3, 4, 3, 2],
      preamp: 0,
    ),
    'Pop': EQPreset(
      name: 'Pop',
      gains: [-2, -1, 0, 2, 3, 2, 0, -1, -2, -2],
      preamp: 0,
    ),
    'Jazz': EQPreset(
      name: 'Jazz',
      gains: [2, 1, -1, 0, -2, -1, 1, 3, 2, 1],
      preamp: 0,
    ),
    'Classical': EQPreset(
      name: 'Classical',
      gains: [1, 0, -2, -3, -2, 0, 2, 3, 2, 0],
      preamp: 0,
    ),
    'Bass Boost': EQPreset(
      name: 'Bass Boost',
      gains: [6, 5, 3, 1, -1, -2, 0, 1, 1, 1],
      preamp: 2,
    ),
    'Vocal': EQPreset(
      name: 'Vocal',
      gains: [-3, -2, 0, 2, 4, 3, 1, 0, -1, -2],
      preamp: 0,
    ),
  };

  static EQSettings createDefault() {
    final bands = <EQBand>[];
    for (int i = 0; i < bandNames.length; i++) {
      bands.add(EQBand(
        name: bandNames[i],
        frequency: bandFrequencies[i],
        gain: 0.0,
      ));
    }
    return EQSettings(
      bands: bands,
      preamp: 0.0,
      activePreset: 'Flat',
      enabled: true,
    );
  }
}

// Riverpod provider for EQ settings
final equalizerProvider =
    StateNotifierProvider<EqualizerNotifier, EQSettings>((ref) {
  return EqualizerNotifier();
});

class EqualizerNotifier extends StateNotifier<EQSettings> {
  static const String _prefsKey = 'eq_settings';

  EqualizerNotifier() : super(EQDefaults.createDefault()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_prefsKey);
      if (jsonString != null) {
        final json = jsonDecode(jsonString);
        state = EQSettings.fromJson(json);
      }
    } catch (e) {
      print('Error loading EQ settings: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, jsonEncode(state.toJson()));
    } catch (e) {
      print('Error saving EQ settings: $e');
    }
  }

  void updateBandGain(int bandIndex, double gain) {
    if (bandIndex >= 0 && bandIndex < state.bands.length) {
      final updatedBands = List<EQBand>.from(state.bands);
      updatedBands[bandIndex] = EQBand(
        name: updatedBands[bandIndex].name,
        frequency: updatedBands[bandIndex].frequency,
        gain: gain.clamp(-12.0, 12.0),
      );
      state = state.copyWith(bands: updatedBands);
      _saveSettings();
    }
  }

  void updatePreamp(double preamp) {
    state = state.copyWith(preamp: preamp.clamp(-6.0, 6.0));
    _saveSettings();
  }

  void applyPreset(String presetName) {
    final preset = EQDefaults.presets[presetName];
    if (preset != null) {
      final bands = <EQBand>[];
      for (int i = 0; i < state.bands.length; i++) {
        bands.add(EQBand(
          name: state.bands[i].name,
          frequency: state.bands[i].frequency,
          gain: preset.gains[i],
        ));
      }
      state = state.copyWith(
        bands: bands,
        preamp: preset.preamp,
        activePreset: presetName,
      );
      _saveSettings();
    }
  }

  void resetToFlat() {
    applyPreset('Flat');
  }

  void toggleEnabled() {
    state = state.copyWith(enabled: !state.enabled);
    _saveSettings();
  }
}
