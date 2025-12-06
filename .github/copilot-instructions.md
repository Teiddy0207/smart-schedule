# AI Coding Agent Instructions for my_app

## Project Overview

**my_app** is a Flutter mobile application targeting multiple platforms (Android, iOS, Linux, macOS, Windows) with a Material Design UI. Currently a template project demonstrating widget composition with Material components. The app is a private package (`publish_to: 'none'`).

**Runtime Environment**: Dart 3.9.2+, Flutter latest stable channel.

## Architecture Patterns

### Widget Structure
- **Single-file organization**: All widgets colocated in `lib/main.dart` for this template project
- **Stateful vs Stateless**: Use `StatefulWidget` for components with mutable state; `StatelessWidget` for purely presentational widgets
- **Widget composition**: Build complex UIs by nesting `StatelessWidget` classes (e.g., `NewWidgetRow`, `RowWidgetColumn`, `RowWidgetAvatar`)
- **Layout hierarchy**: Preferred containers: `Scaffold` → `SafeArea` → `SingleChildScrollView` → `Padding` → `Column`/`Row`

### Key Components in main.dart
- `Home` (StatefulWidget): Root screen with AppBar and scrollable body
- `NewWidgetRow` (StatelessWidget): Demonstrates Row with fixed/expanded children
- `RowWidgetColumn` (StatelessWidget): Nested Row→Column structure with dividers
- `RowWidgetAvatar` (StatelessWidget): CircleAvatar with layered Stack children

## Development Workflows

### Build & Run Commands
```bash
# Run app on connected device/emulator
flutter run -d emulator-5554        # Specific device ID

# Debug mode (development)
flutter run -d emulator-5554 --debug

# Release build (optimized)
flutter run -d emulator-5554 --release

# Hot reload after code changes
# Press 'r' in terminal running 'flutter run'
```

### Testing
```bash
# Run all widget tests in test/
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Widget test pattern: Use WidgetTester.pump() to trigger frames and find() to locate widgets
# See test/widget_test.dart for the counter app smoke test example
```

### Code Analysis & Formatting
```bash
# Analyze code for errors/warnings
flutter analyze

# Auto-format code (uses dartfmt)
dart format lib/

# Apply lint fixes
dart fix --apply
```

## Project-Specific Conventions

### Material Design Compliance
- Use `MaterialApp` with `debugShowCheckedModeBanner: false` at app root
- AppBar styling: Use predefined colors (`Colors.lightBlue`) and TextStyle properties (`fontSize`, `fontWeight`, `letterSpacing`)
- Consistent padding: Use `EdgeInsets.all(16.0)` for standard spacing

### Lint Rules
- `flutter_lints` (v5.0.0+) enabled in `analysis_options.yaml`
- Avoid `print()` statements (use logging framework for production)
- Default to double quotes (not single quotes) unless style guide differs

### File Structure
```
lib/
  main.dart              # All app code (entry point + widget classes)
test/
  widget_test.dart       # Widget integration tests
android/, ios/, etc.     # Platform-specific native code (generated/configured)
```

## Integration Points & Dependencies

### External Dependencies
- **flutter**: Core SDK (Material widgets, BuildContext, State management)
- **cupertino_icons** (v1.0.8+): iOS-style icons (imported but optional)
- **flutter_lints**: Static analysis rules

### Platform-Specific Behavior
- **Android**: Build via Gradle (android/build.gradle.kts); version controlled in pubspec.yaml
- **iOS**: Build via Xcode; Flutter config in ios/Flutter/*.xcconfig
- **Desktop (Linux/macOS/Windows)**: CMake builds, generated plugin registration

## Critical Developer Practices

### State Management
- Currently using basic `State<T>` pattern; no Provider/Riverpod/GetX dependency
- Widget rebuild triggered via `setState()` (not shown in current template but standard pattern)

### Hot Reload Limitations
- Hot reload does NOT work for:
  - Main app initialization (runApp changes)
  - Global variables/top-level state changes
  - New class definitions
- Use full hot restart (press 'R' in terminal) for these cases

### Widget Testing
- Use `WidgetTester` (from flutter_test) for UI interaction testing
- Always call `await tester.pump()` or `await tester.pumpWidget()` to trigger frame builds
- Use `find.byType()`, `find.byIcon()`, `find.text()` to locate widgets in tree

## Common Troubleshooting

| Issue | Solution |
|-------|----------|
| "flutter: command not found" | Add Flutter bin/ to PATH; run `flutter doctor -v` to verify |
| App crashes on hot reload | Use hot restart (R) instead; check for mutable statics |
| Widget not appearing in tree | Verify parent widget (Column/Row) has proper constraints; check Expanded usage |
| Test fails with pump timeout | Increase `timeout` in test runner or reduce animation complexity |

## Next Steps for Expansion

When scaling this template, consider:
1. **Folder structure**: Migrate to `lib/features/` or `lib/modules/` as app grows beyond single file
2. **State management**: Evaluate Provider, Riverpod, or GetX when app reaches 2+ screens
3. **Navigation**: Add GoRouter or auto_route for multi-screen navigation
4. **API integration**: Add http or dio package + ChangeNotifier/Service layer
5. **Localization**: Enable intl package for i18n support
