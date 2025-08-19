/// Flutter Hardcode Localizer
///
/// A tool for finding hardcoded strings in Flutter projects and
/// providing quick-fix functionality to move them to localization files.
///
/// - Seamless integration with easy_localization package
/// - Generates LocaleKeys.key.tr() format automatically
/// - Eliminates manual process of adding JSON key-values
/// - Perfect companion for easy_localization workflow!
library;

export 'src/hardcode_detector.dart';
export 'src/json_manager.dart';
export 'src/code_transformer.dart';
export 'src/string_utils.dart';

import 'dart:io';
import 'package:path/path.dart' as p;
import 'src/hardcode_detector.dart';
import 'src/json_manager.dart';
import 'src/code_transformer.dart';

/// Main entry point for running the localization transformation tool.
///
/// - Scans all Dart files in [projectPath]/lib for hardcoded strings.
/// - [autoApproveSuggestedKeys] automatically accepts developer consent for localisation
/// - [skipFiles] ignores the listed files in process
/// - Provides interactive CLI for deciding which strings to localize (with custom key support).
/// - Automatically updates assets/languages/en.json and replaces source code with LocaleKeys references.
/// - Handles duplicate keys, context-aware user prompts, and robust error handling.
/// - Prints a summary at the end and next steps for easy_localization users.
Future<void> runLocalizationTool(String projectPath,
    bool autoApproveSuggestedKeys, List<String> skipFiles) async {
  final libDir = Directory(p.join(projectPath, 'lib'));

  // Validates there is a 'lib' folder. Throws error if missing.
  if (!libDir.existsSync()) {
    throw Exception('No lib folder found at $projectPath');
  }

  // Inform user about workflow being started.
  print('🔍 Scanning for hardcoded strings...');
  print('✨ Generating LocaleKeys.key.tr() format for easy_localization');
  print('🎯 Automating the manual JSON key-value creation process');
  print('');

  // Instantiate utility classes for detection, management, and code transformation.
  final detector = HardcodeDetector();
  final jsonManager = JsonManager(projectPath);
  final transformer = CodeTransformer();

  // Find all Dart files in the lib directory.
  final dartFiles = libDir
      .listSync(recursive: true)
      .where((f) => f.path.endsWith('.dart'))
      .cast<File>();

  var totalStringFound = 0;
  var totalStringProcessed = 0;

  // Process each Dart file and ask about each hardcoded string.
  for (final file in dartFiles) {
    final relativePath = p.relative(file.path, from: projectPath);

    bool canSkipFile = skipFiles
        .any((test) => test.toLowerCase() == relativePath.toLowerCase());

    if (canSkipFile) {
      print('   ⏭️  Skipped $relativePath');
      continue;
    }
    print('📄 Processing: $relativePath');

    // Discover all localizable hardcoded strings.
    final hardcodedStrings = await detector.findHardcodedStrings(file);

    if (hardcodedStrings.isEmpty) {
      print('   ✅ No hardcoded strings found');
      continue;
    }

    totalStringFound += hardcodedStrings.length;
    print('   🔍 Found ${hardcodedStrings.length} hardcoded string(s)');

    // Collect replacements for batch processing after user prompts.
    final replacements = <MapEntry<HardcodedStringInfo, String>>[];

    for (final stringInfo in hardcodedStrings) {
      print('');
      print('   📝 Found: "${stringInfo.value}"');
      print('   📍 Line ${stringInfo.line}:${stringInfo.column}');

      // Show relevant code context for where string occurs
      await _showStringContext(stringInfo, file);

      String key = stringInfo.suggestedKey;
      if (autoApproveSuggestedKeys) {
        // Auto-approve localization for all strings
        print(
            '   ✅ Auto-approved localization for: "${stringInfo.value}" with key "$key"');
      } else {
        // Prompt for localization decision (yes/no/custom key)
        stdout.write('   ❓ Move to localization? (y/n/c for custom key): ');
        final input = stdin.readLineSync()?.toLowerCase();

        if (input == null || input == 'n') {
          print('   ⏭️  Skipped');
          continue;
        }

        if (input == 'c') {
          stdout.write('   🔑 Enter custom key: ');
          key = stdin.readLineSync() ?? '';
          if (key.isEmpty) {
            print('   ❌ Invalid key, skipping');
            continue;
          }
        } else {
          key = stringInfo.suggestedKey;
        }
      }

      bool addToJson = true;

      // Handle duplicates: prompt user to use a different key if it’s taken
      if (await jsonManager.keyExists(key)) {
        print('   ⚠️  Key "$key" already exists in en.json');
        stdout.write('   ❓ Use different key? (y/n/s): ');
        final enteredOption = stdin.readLineSync()?.toLowerCase();

        final useOther = enteredOption == 'y';
        final skipKey = enteredOption == 's';
        final useSameKey = enteredOption == 'n';

        if (useOther) {
          stdout.write('   🔑 Enter new key: ');
          final newKey = stdin.readLineSync();
          if (newKey != null && newKey.isNotEmpty) {
            key = newKey;
          } else {
            print('   ❌ Invalid key, skipping');
            continue;
          }
        } else if (skipKey) {
          print('   ⏭️  Skipped due to duplicate key');
          continue;
        } else if (useSameKey) {
          addToJson = false;
        } else {
          print('   ⏭️  Skipped due to invalid input');
          continue;
        }
      }

      if (addToJson) {
        // Add key-value translation and record for code replacement.
        await jsonManager.addTranslation(key, stringInfo.value);
        print('   ✅ Added "$key": "${stringInfo.value}" to en.json');
      } else {
        // Reused same json key to replace in code
        print('   ♻️ Reused "$key": "${stringInfo.value}" from en.json');
      }

      replacements.add(MapEntry(stringInfo, key));

      totalStringProcessed++;
    }

    // Apply all replacements at once, fallback to individual replacements if needed
    if (replacements.isNotEmpty) {
      try {
        await transformer.replaceMultipleStrings(file, replacements);
        print('\n');
        print(
            '   ✨ Applied ${replacements.length} LocaleKeys.key.tr() replacement(s)');
      } catch (e) {
        print('   ❌ Failed to apply batch replacements: $e');
        print('   🔄 Trying individual replacements...');

        var successCount = 0;
        for (final replacement in replacements) {
          try {
            await transformer.replaceStringWithLocale(
                file, replacement.key, replacement.value);
            print(
                '   ✅ Replaced "${replacement.key.value}" with LocaleKeys.${replacement.value}.tr()');
            successCount++;
          } catch (e) {
            print('   ❌ Failed to replace "${replacement.key.value}": $e');
          }
        }
        if (successCount > 0) {
          print(
              '   ✨ Successfully applied $successCount individual replacement(s)');
        }
      }
    }

    print('');
  }

  // Print end-of-run summary and guidance for next steps
  print('📊 Summary:');
  print('   🔍 Total hardcoded strings found: $totalStringFound');
  print('   ✅ Strings processed: $totalStringProcessed');
  print('   ⏭️  Strings skipped: ${totalStringFound - totalStringProcessed}');

  if (totalStringProcessed > 0) {
    print('');
    print('🎉 Localization completed successfully!');
    print('');
    print('📋 Next steps for easy_localization:');
    print('   1. Run: flutter packages pub run easy_localization:generate');
    print('   2. This will generate LocaleKeys from your en.json file');
    print('   3. Add import: import "generated/locale_keys.g.dart";');
    print('   4. Your strings are now using LocaleKeys.key.tr() format!');
    print('   5. Test your application');
    print('');
    print('✨ No more manual JSON key-value creation needed!');
    print('✨ Thanks for using Flutter Hardcode Localizer!');
  }
}

/// Show additional context about where the string is located in source code.
///
/// Prints a description if the string is part of an array, map, method/constructor,
/// or a long/informative line. This helps users understand what they're localizing.
Future<void> _showStringContext(
    HardcodedStringInfo stringInfo, File file) async {
  try {
    final lines = await file.readAsLines();
    final lineIndex = stringInfo.line - 1;

    if (lineIndex >= 0 && lineIndex < lines.length) {
      final line = lines[lineIndex].trim();

      // Print context depending on detected structure type
      if (line.contains('[') && line.contains(']')) {
        print('   📍 Context: Array/List → ${_truncate(line, 60)}');
      } else if (line.contains('{') && line.contains('}')) {
        print('   📍 Context: Map/Object → ${_truncate(line, 60)}');
      } else if (line.contains('(') && line.contains(')')) {
        print('   📍 Context: Method/Constructor → ${_truncate(line, 60)}');
      } else if (line.length > 50) {
        print('   📍 Context: ${_truncate(line, 60)}');
      }
    }
  } catch (e) {
    // Ignore context extraction errors, -- not critical for workflow.
  }
}

/// Truncate a string to [maxLength] characters for readable CLI output.
String _truncate(String text, int maxLength) {
  if (text.length <= maxLength) return text;
  return '${text.substring(0, maxLength - 3)}...';
}
