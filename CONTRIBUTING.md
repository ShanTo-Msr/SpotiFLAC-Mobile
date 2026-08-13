# Contributing to SpotiFLAC Mobile

Thank you for your interest in contributing to SpotiFLAC Mobile! This guide will help you get started with development on this iOS-only project.

## Project Status

**iOS Only**: SpotiFLAC Mobile is currently an iOS application. Android support has been removed as of this version. All contributions should target iOS (v14.0+).

## Development Setup

### System Requirements

- **macOS** 12.0 or later
- **Xcode** 15.0 or later
- **Xcode Command Line Tools**
- **Flutter** (via FVM or direct install)
- **CocoaPods** (usually included with Xcode)
- **Go** 1.21+ (for backend optional features)

### Step 1: Clone the Repository

```bash
git clone https://github.com/ShanTo-Msr/SpotiFLAC-Mobile.git
cd SpotiFLAC-Mobile
```

### Step 2: Install Flutter

Using **FVM** (recommended):
```bash
brew install fvm
fvm install
fvm flutter pub get
```

Or manually:
```bash
flutter pub get
```

The Flutter version is pinned in `.fvmrc`.

### Step 3: Install iOS Dependencies

```bash
cd ios
pod install --repo-update
cd ..
```

### Step 4: Verify Setup

```bash
flutter doctor
flutter analyze
```

## Workflow

### Before You Start

1. **Create a branch** off `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Keep it focused**: One feature or bugfix per branch

3. **Reference issues**: If your work addresses an issue, reference it in commit messages
   ```bash
   git commit -m "fix: issue description (#123)"
   ```

### Code Style

#### Dart/Flutter

- Follow the [Effective Dart: Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Run formatter and analyzer before committing:
  ```bash
  dart format lib/
  flutter analyze
  ```
- Use meaningful variable and function names
- Keep lines under 100 characters when possible
- Add documentation comments for public APIs:
  ```dart
  /// Applies the equalizer settings to the audio engine.
  /// 
  /// [gains] must contain exactly 10 values between -12.0 and 12.0 dB.
  /// [preamp] must be between -6.0 and 6.0 dB.
  void applyEQSettings({
    required List<double> gains,
    required double preamp,
  }) { ... }
  ```

#### Swift

- Follow [Apple's Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use meaningful names (full words, no abbreviations)
- Add MARK comments for organization:
  ```swift
  // MARK: - Setup
  // MARK: - Playback Control
  // MARK: - EQ Control
  ```
- Document complex functions with doc comments:
  ```swift
  /// Configures the 10-band parametric equalizer with standard frequencies.
  /// Bands are 31 Hz, 62 Hz, 125 Hz, ... 16 kHz.
  private func setupEQBands() { ... }
  ```
- Use proper error handling (try-catch, guard statements)

#### Go

- Run `gofmt` on all Go files
- Use `go vet` to check for issues:
  ```bash
  cd go_backend
  gofmt -w .
  go vet ./...
  ```

### Testing

#### Flutter/Dart Tests

```bash
flutter test
```

- Add unit tests for new Dart functions
- Place tests in `test/` directory
- Name test files with `_test.dart` suffix

#### Manual Testing on iOS

1. **Run on device**:
   ```bash
   flutter run -d "<device_id>" --release
   ```

2. **Run on simulator**:
   ```bash
   flutter run -d "iPhone 15 Pro" --release
   ```

3. **Test equalizer features**:
   - Navigate to Settings
   - Toggle "Use Internal Player" on/off
   - Open Equalizer screen and verify:
     - Sliders are responsive
     - Presets can be applied
     - Settings persist after app restart
     - Audio playback works (requires physical device for audible testing)

4. **Check logs**:
   ```bash
   flutter logs
   ```

### Commits and PRs

#### Commit Messages

Use conventional commits for clarity:

```
feat: add 10-band equalizer UI screen
fix: correct EQ band frequency mapping
refactor: simplify platform channel error handling
docs: add equalizer settings documentation
test: add unit tests for EQ provider
chore: update dependencies
```

#### Pull Request Template

When opening a PR, include:

1. **Description**: What does this PR do?
2. **Motivation**: Why is this change needed?
3. **Testing**: How did you test this?
4. **Checklist**:
   - [ ] Code follows style guidelines
   - [ ] `flutter analyze` passes
   - [ ] Tests added/updated (if applicable)
   - [ ] Manual testing on iOS device/simulator
   - [ ] PR is based on latest `main`
   - [ ] Documentation updated (README, CONTRIBUTING, code comments)

#### Review Process

- At least one maintainer review required
- All CI checks must pass
- Address feedback promptly
- Rebase on `main` if there are conflicts

## Project Structure

```
SpotiFLAC-Mobile/
├── lib/                           # Dart/Flutter source code
│   ├── features/
│   │   ├── equalizer/            # Equalizer UI and logic
│   │   │   └── screens/
│   │   │       └── equalizer_screen.dart
│   │   └── settings/              # Settings and preferences
│   │       └── screens/
│   │           └── settings_screen.dart
│   ├── providers/
│   │   ├── equalizer_provider.dart     # EQ state management (Riverpod)
│   │   └── internal_player_provider.dart # Player toggle state
│   ├── services/
│   │   └── ios_audio_player_channel.dart # Platform channel bridge
│   └── main.dart
├── ios/                           # iOS-specific code
│   ├── Runner/
│   │   ├── IOSAudioPlayer.swift   # AVAudioEngine implementation
│   │   ├── IOSAudioPlayerPlugin.swift # Platform channel handler
│   │   ├── GeneratedPluginRegistrant.swift (auto-generated)
│   │   └── ...
│   ├── Podfile                    # CocoaPods dependencies
│   └── Runner.xcodeproj
├── go_backend/                    # Go backend (optional)
│   ├── go.mod
│   ├── go.sum
│   └── main.go
├── .github/
│   └── workflows/
│       ├── ci.yml                 # Flutter and Go tests
│       └── release.yml            # iOS IPA builds
├── pubspec.yaml                   # Flutter dependencies
├── README.md                      # User documentation
├── CONTRIBUTING.md                # This file
└── .fvmrc                         # Flutter version pin
```

## Important Files

### Configuration

- **pubspec.yaml**: Flutter/Dart dependencies and app config
- **ios/Podfile**: iOS CocoaPods dependencies
- **.github/workflows/**: CI/CD configuration (Flutter tests, iOS builds)
- **.fvmrc**: Flutter version (use FVM to manage)

### Platform Channel

- **lib/services/ios_audio_player_channel.dart**: Dart side of platform channel
- **ios/Runner/IOSAudioPlayerPlugin.swift**: Swift plugin that receives calls
- **ios/Runner/IOSAudioPlayer.swift**: Core audio engine implementation

## Common Development Tasks

### Adding a New Feature

1. Create a feature branch: `git checkout -b feature/new-feature`
2. Add Flutter code in `lib/features/<feature>/`
3. If iOS-specific logic is needed, add Swift files in `ios/Runner/`
4. Update platform channel if adding native calls
5. Add tests in `test/`
6. Update README if user-facing
7. Submit PR with detailed description

### Modifying the Equalizer

1. **Dart side** (UI/state): Edit `lib/providers/equalizer_provider.dart` and `lib/features/equalizer/screens/equalizer_screen.dart`
2. **Swift side** (audio processing): Edit `ios/Runner/IOSAudioPlayer.swift`
3. **Platform channel**: Update `lib/services/ios_audio_player_channel.dart` if adding new methods
4. Test on physical device with audio playing

### Building for Release

**GitHub Actions** automatically builds and creates releases when you tag a commit:

```bash
git tag v1.0.0
git push origin v1.0.0
```

For manual builds:

```bash
# iOS IPA
flutter build ios --release

# Output: build/ios/ipa/
```

## Troubleshooting

### CocoaPods Issues

```bash
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
cd ..
flutter clean
flutter pub get
```

### Xcode Build Errors

Always use the `.xcworkspace` file:

```bash
open ios/Runner.xcworkspace
```

Not `.xcodeproj`.

### Flutter Pub Issues

```bash
flutter clean
flutter pub get
flutter pub upgrade
```

### Platform Channel Not Found

Ensure iOS plugin is registered. Check `GeneratedPluginRegistrant.swift` in Xcode:

```bash
flutter clean
cd ios
pod install
cd ..
flutter run
```

## Questions?

- Check [GitHub Issues](https://github.com/ShanTo-Msr/SpotiFLAC-Mobile/issues)
- Open a [Discussion](https://github.com/ShanTo-Msr/SpotiFLAC-Mobile/discussions)
- Review existing PRs for patterns

## Code of Conduct

Be respectful, inclusive, and constructive. We welcome all skill levels.

---

**Thank you for contributing to SpotiFLAC Mobile!** 🎵
