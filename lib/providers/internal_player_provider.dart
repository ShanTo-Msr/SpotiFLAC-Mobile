import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider for internal player toggle state
final internalPlayerEnabledProvider =
    StateNotifierProvider<InternalPlayerNotifier, bool>((ref) {
  return InternalPlayerNotifier();
});

class InternalPlayerNotifier extends StateNotifier<bool> {
  static const String _prefsKey = 'use_internal_player';

  InternalPlayerNotifier() : super(false) {
    _loadPreference();
  }

  Future<void> _loadPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = prefs.getBool(_prefsKey) ?? false;
    } catch (e) {
      print('Error loading internal player preference: $e');
    }
  }

  Future<void> toggleInternalPlayer() async {
    state = !state;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefsKey, state);
    } catch (e) {
      print('Error saving internal player preference: $e');
    }
  }
}
