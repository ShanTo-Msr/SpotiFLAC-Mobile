import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotififlac/providers/equalizer_provider.dart';
import 'package:spotififlac/services/ios_audio_player_channel.dart';

/// Equalizer Settings Screen
class EqualizerScreen extends ConsumerStatefulWidget {
  const EqualizerScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<EqualizerScreen> createState() => _EqualizerScreenState();
}

class _EqualizerScreenState extends ConsumerState<EqualizerScreen> {
  @override
  void initState() {
    super.initState();
    // Apply initial EQ settings when screen opens
    _applyCurrentSettings();
  }

  Future<void> _applyCurrentSettings() async {
    final settings = ref.read(equalizerProvider);
    try {
      await IOSAudioPlayerChannel.applyEQSettings(
        gains: settings.bands.map((b) => b.gain).toList(),
        preamp: settings.preamp,
        enabled: settings.enabled,
      );
    } catch (e) {
      print('Error applying EQ settings: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(equalizerProvider);
    final notifier = ref.read(equalizerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Equalizer'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Master EQ Toggle
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Enable Equalizer',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Switch(
                        value: settings.enabled,
                        onChanged: (value) async {
                          notifier.toggleEnabled();
                          try {
                            await IOSAudioPlayerChannel.setEQEnabled(value);
                          } catch (e) {
                            print('Error toggling EQ: $e');
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Preamp Control
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Preamp',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${settings.preamp.toStringAsFixed(1)} dB',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Slider(
                        value: settings.preamp,
                        min: -6,
                        max: 6,
                        divisions: 24,
                        onChanged: (value) async {
                          notifier.updatePreamp(value);
                          try {
                            await IOSAudioPlayerChannel.setEQPreamp(value);
                          } catch (e) {
                            print('Error setting preamp: $e');
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // EQ Bands
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '10-Band Equalizer',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...List.generate(
                        settings.bands.length,
                        (index) => _buildBandSlider(
                          context,
                          index,
                          settings.bands[index],
                          notifier,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Presets
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Presets',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: EQDefaults.presets.keys.map((presetName) {
                          final isActive = settings.activePreset == presetName;
                          return FilterChip(
                            label: Text(presetName),
                            selected: isActive,
                            onSelected: (selected) async {
                              if (selected) {
                                notifier.applyPreset(presetName);
                                try {
                                  final preset =
                                      EQDefaults.presets[presetName]!;
                                  await IOSAudioPlayerChannel.applyEQSettings(
                                    gains: preset.gains,
                                    preamp: preset.preamp,
                                    enabled: settings.enabled,
                                  );
                                } catch (e) {
                                  print('Error applying preset: $e');
                                }
                              }
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Reset Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    notifier.resetToFlat();
                    try {
                      await IOSAudioPlayerChannel.resetEQ();
                    } catch (e) {
                      print('Error resetting EQ: $e');
                    }
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset to Flat'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[400],
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBandSlider(
    BuildContext context,
    int index,
    EQBand band,
    EqualizerNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              band.name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${band.gain.toStringAsFixed(1)} dB',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: band.gain,
          min: -12,
          max: 12,
          divisions: 24,
          onChanged: (value) async {
            notifier.updateBandGain(index, value);
            try {
              await IOSAudioPlayerChannel.setEQBandGain(index, value);
            } catch (e) {
              print('Error setting EQ band: $e');
            }
          },
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
