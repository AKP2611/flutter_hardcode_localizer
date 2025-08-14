import 'dart:io';
import 'package:flutter_hardcode_localizer/src/json_manager.dart';
import 'package:test/test.dart';

void main() {
  group('JsonManager v1.0.1 - assets/languages Integration', () {
    late Directory tempDir;
    late JsonManager jsonManager;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('test_languages_');
      jsonManager = JsonManager(tempDir.path);
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('should create JSON file in assets/languages directory', () async {
      await jsonManager.addTranslation('helloWorld', 'Hello World');
      await jsonManager.addTranslation('saveDocument', 'Save Document');
      await jsonManager.addTranslation('clickMe', 'Click Me');

      final jsonFile = File('\${tempDir.path}/assets/languages/en.json');
      expect(jsonFile.existsSync(), isTrue);

      final content = await jsonFile.readAsString();
      expect(content, contains('"clickMe": "Click Me"'));
      expect(content, contains('"helloWorld": "Hello World"'));
      expect(content, contains('"saveDocument": "Save Document"'));
    });

    test('should maintain sorted keys for easy_localization', () async {
      await jsonManager.addTranslation('zebra', 'Zebra');
      await jsonManager.addTranslation('apple', 'Apple');
      await jsonManager.addTranslation('banana', 'Banana');

      final jsonFile = File('\${tempDir.path}/assets/languages/en.json');
      final content = await jsonFile.readAsString();

      final appleIndex = content.indexOf('"apple"');
      final bananaIndex = content.indexOf('"banana"');
      final zebraIndex = content.indexOf('"zebra"');

      expect(appleIndex < bananaIndex, isTrue);
      expect(bananaIndex < zebraIndex, isTrue);
    });

    test('should create assets/languages directory structure', () async {
      await jsonManager.addTranslation('test', 'Test Value');

      final assetsDir = Directory('\${tempDir.path}/assets');
      final languagesDir = Directory('\${tempDir.path}/assets/languages');

      expect(assetsDir.existsSync(), isTrue);
      expect(languagesDir.existsSync(), isTrue);
    });
  });
}