import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

class JsonManager {
  final String projectPath;
  late final String jsonPath;
  Map<String, dynamic> _translations = {};

  JsonManager(this.projectPath) {
    // Updated path to match easy_localization convention: assets/languages/
    jsonPath = p.join(projectPath, 'assets/languages', 'en.json');
    _loadTranslations();
  }

  void _loadTranslations() {
    final file = File(jsonPath);
    if (file.existsSync()) {
      try {
        final content = file.readAsStringSync();
        _translations = json.decode(content) as Map<String, dynamic>;
      } catch (e) {
        print('⚠️  Warning: Could not parse existing en.json: $e');
        _translations = {};
      }
    } else {
      _translations = {};
    }
  }

  Future<bool> keyExists(String key) async {
    return _translations.containsKey(key);
  }

  Future<void> addTranslation(String key, String value) async {
    _translations[key] = value;
    await _saveTranslations();
  }

  Future<void> _saveTranslations() async {
    final file = File(jsonPath);

    // Ensure directory exists
    await file.parent.create(recursive: true);

    // Sort keys for consistent output
    final sortedMap = Map<String, dynamic>.fromEntries(
      _translations.entries.toList()..sort((a, b) => a.key.compareTo(b.key))
    );

    // Pretty print JSON
    const encoder = JsonEncoder.withIndent('  ');
    final jsonString = encoder.convert(sortedMap);

    await file.writeAsString(jsonString);
  }

  Map<String, dynamic> get translations => Map.unmodifiable(_translations);
}