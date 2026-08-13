# SpotiFLAC Mobile — iOS-only Edition

A high-quality FLAC player for iOS with native 10-band equalizer support.

## Features

### Core Playback
- **FLAC & Audio Format Support**: Play FLAC, MP3, WAV, and other common audio formats on iOS
- **High-Quality Audio**: Optimized for local file playback with full bitrate support
- **History & Library**: Organize and track your listening history

### Advanced Equalizer (iOS)
- **10-Band Parametric EQ**: Fine-tune audio with individual control over 10 frequency bands (31 Hz – 16 kHz)
- **Built-in Presets**:
  - Flat (neutral)
  - Rock (bass & treble boost)
  - Pop (midrange emphasis)
  - Jazz (smooth, balanced)
  - Classical (wide frequency response)
  - Bass Boost (low-end enhancement)
  - Vocal (vocal clarity)
  - Custom (user-defined)
- **Preamp Control**: Global gain adjustment (±6 dB)
- **Persistent Settings**: EQ preferences are automatically saved and restored

### Optional Internal Player
- **AVAudioEngine-based Player**: Native iOS audio engine with hardware-accelerated processing
- **Opt-in Design**: Disabled by default; enable in Settings → Use Internal Player
- **Full EQ Support**: The internal player routes audio through the 10-band EQ

## Platform Support

**iOS Only** (v14.0+)

- No Android version currently maintained
- Requires physical iOS device for full audio playback testing (EQ audio behavior may be limited on simulator)

## Getting Started

### Prerequisites
- **macOS** with Xcode 15+
- **Xcode Command Line Tools**
- **Flutter** (stable channel, pinned in `.fvmrc`)
- **CocoaPods** (for iOS dependency management)
- **Go** (for backend build; check `go_backend/go.mod`)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/ShanTo-Msr/SpotiFLAC-Mobile.git
   cd SpotiFLAC-Mobile
   ```

2. **Setup Flutter environment**
   ```bash
   flutter pub get
   flutter clean
   ```

3. **Build for iOS**
   ```bash
   flutter build ios --release
   ```

   > **Note**: Unsigned builds require an Apple Developer account for device deployment. See [Device Testing](#device-testing) below.

## Device Testing

### Physical Device

1. **Provisioning Profile**: You need a valid provisioning profile and team ID from Apple Developer
   ```bash
   # Open Xcode project
   open ios/Runner.xcworkspace
   ```

2. **Build & Run on Device**
   ```bash
   flutter run -d <device_id> --release
   ```

3. **Using Sideload Tools** (TestFlight, AltStore, Sideloadly)
   - Build the unsigned IPA
   - Use a sideload service to deploy the app
   - Requires valid provisioning or free Developer ID

### Simulator

**Note**: Simulator has limited audio hardware support. EQ audio effects may not be audible. For proper testing, use a physical device.

```bash
flutter run -d "<simulator_name>" --release
```

## Configuration

### Audio Settings
- **Internal Player Toggle**: Settings → Use Internal Player (disabled by default)
- **Equalizer**: Settings → Equalizer (only visible when internal player is enabled)
- **Presets**: Quick-apply presets from the Equalizer screen

### Build Signing

Edit `ios/Runner.xcodeproj` in Xcode to configure your provisioning profile and team ID before building for a physical device.

## Architecture

### Flutter (Dart)
- **UI Layer**: Material design interface for playback, library, and EQ control
- **State Management**: Riverpod for reactive state (equalizer settings, internal player toggle)
- **Persistence**: SharedPreferences for EQ settings and player preferences

### iOS (Swift)
- **Audio Engine**: AVAudioEngine with AVAudioUnitEQ for 10-band parametric equalization
- **Playback**: AVAudioPlayerNode for file playback
- **Platform Channel**: Flutter MethodChannel (`com.spotififlac/ios_audio_player`) bridges Dart and native code

### Backend (Go)
- Optional: Go backend for server-side features (sidecar binary, not required for local playback)

## Contributing

### Code Style
- **Flutter/Dart**: Follow the [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- **Swift**: Follow Apple's [Swift style guide](https://swift.org/documentation/api-design-guidelines/)
- **Go**: Run `gofmt` and `go vet` before submitting

### Testing

1. **Flutter Tests**
   ```bash
   flutter test
   ```

2. **Dart Analysis**
   ```bash
   flutter analyze
   ```

3. **Manual Testing on Device**
   - Enable internal player in Settings
   - Open Equalizer screen
   - Apply different presets and verify audio output
   - Test manual band adjustments
   - Verify settings persist after app restart

### Manual Test Checklist

- [ ] App launches and loads library
- [ ] Internal player toggle persists after restart
- [ ] Equalizer presets load correctly
- [ ] EQ band sliders respond to input
- [ ] Preamp slider adjusts overall volume
- [ ] Playback works with internal player enabled
- [ ] EQ settings persist across app sessions
- [ ] Reset to Flat button restores default gains
- [ ] Custom preset can be created and saved

## Troubleshooting

### Build Issues

**CocoaPods dependency conflict**
```bash
cd ios
pod repo update
pod install --repo-update
cd ..
flutter clean
flutter pub get
```

**Xcode build error**
```bash
open ios/Runner.xcworkspace  # Use .xcworkspace, NOT .xcodeproj
```

### Runtime Issues

**Internal player not playing audio**
- Ensure "Use Internal Player" is enabled in Settings
- Check device volume is not muted
- Verify audio file exists and is readable
- Try disabling EQ and resetting to Flat

**EQ changes not taking effect**
- Ensure internal player is enabled
- Stop and resume playback to apply new EQ settings
- Check app logs for platform channel errors

**Audio glitching or dropout**
- Lower EQ band gains to reduce CPU load
- Close other audio apps
- Restart the app and device

## Release Notes

See [Releases](https://github.com/ShanTo-Msr/SpotiFLAC-Mobile/releases) for version history and change logs.

## License

See [LICENSE](LICENSE) file for details.

## Acknowledgments

- **AVAudioEngine**: Apple's audio processing framework
- **Flutter**: Google's cross-platform framework
- **Community**: Contributors and testers
