import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

/// JsonManager
///
/// Handles reading, writing, and updating translation key-value pairs
/// for localization workflows (specifically easy_localization).
///
/// Writes to `assets/languages/en.json` by default and guarantees sorted,
/// pretty-printed output.
///
/// All logic is encapsulated for safe updates, error handling, and
/// transparent state management.
class JsonManager {
  /// Directory of the Flutter project (absolute or relative)
  final String projectPath;

  /// Path to the translations JSON file (e.g., assets/languages/en.json)
  late final String jsonPath;

  /// In-memory representation of all loaded/translatable values
  Map<String, dynamic> _translations = {};

  /// Construct, initializing [jsonPath] and loading current translations
  ///
  /// - [projectPath]: Root directory of the Flutter project.
  /// - Always uses `assets/languages/en.json` to match easy_localization.
  JsonManager(this.projectPath) {
    // Updated path to match easy_localization convention: assets/languages/
    jsonPath = p.join(projectPath, 'assets/languages', 'en.json');
    _loadTranslations();
  }

  /// Load translation key-value pairs from disk into memory.
  ///
  /// Handles file-not-found, and logs parsing errors without crashing.
  /// Ensures [_translations] is always a valid map (even if empty).
  void _loadTranslations() {
    final file = File(jsonPath);
    if (file.existsSync()) {
      try {
        final content = file.readAsStringSync();
        _translations = json.decode(content) as Map<String, dynamic>;
      } catch (e) {
        print('⚠️  Warning: Could not parse existing en.json: $e');
        _translations = {}; // Start fresh if corrupt
      }
    } else {
      _translations = {}; // New file; nothing loaded
    }
  }

  /// Checks if the provided localization [key] already exists in memory.
  ///
  /// Use this before adding or updating a key to prevent duplicates!
  Future<bool> keyExists(String key) async {
    return _translations.containsKey(key);
  }

  /// Add a new translation pair (key-value) and save immediately.
  ///
  /// Updates the in-memory map and synchronizes with disk.
  Future<void> addTranslation(String key, String value) async {
    _translations[key] = value;
    await _saveTranslations();
  }

  /// Write the current [_translations] map back to disk.
  ///
  /// - Ensures parent directory is created first.
  /// - Sorts keys alphabetically for easy diffs and codegen.
  /// - Pretty-prints JSON for further manual editing.
  Future<void> _saveTranslations() async {
    final file = File(jsonPath);

    // Ensure directory exists (never fails if already present)
    await file.parent.create(recursive: true);

    // Sort keys for consistency and easy comparison/version control
    final sortedMap = Map<String, dynamic>.fromEntries(
        _translations.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));

    // Pretty-print JSON to disk
    const encoder = JsonEncoder.withIndent('  ');
    final jsonString = encoder.convert(sortedMap);

    await file.writeAsString(jsonString);
  }

  /// Returns an unmodifiable view of translations for external inspection or codegen.
  ///
  /// This ensures outside code cannot accidentally modify translation data.
  Map<String, dynamic> get translations => Map.unmodifiable(_translations);
}
