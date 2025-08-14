/// Flutter Hardcode Localizer v1.0.1
/// 
/// A tool for finding hardcoded strings in Flutter projects and 
/// providing quick-fix functionality to move them to localization files.
/// 
/// ENHANCED IN v1.0.1:
/// - Seamless integration with easy_localization package
/// - Generates LocaleKeys.key.tr() format automatically  
/// - Eliminates manual process of adding JSON key-values
/// - Perfect companion for easy_localization workflow
library flutter_hardcode_localizer;

export 'src/hardcode_detector.dart';
export 'src/json_manager.dart';
export 'src/code_transformer.dart';
export 'src/string_utils.dart';

import 'dart:io';
import 'package:path/path.dart' as p;
import 'src/hardcode_detector.dart';
import 'src/json_manager.dart';
import 'src/code_transformer.dart';

/// Main function to run the localization tool
Future<void> runLocalizationTool(String projectPath) async {
  final libDir = Directory(p.join(projectPath, 'lib'));

  if (!libDir.existsSync()) {
    throw Exception('No lib folder found at $projectPath');
  }

  print('🔍 Scanning for hardcoded strings...');
  print('✨ Generating LocaleKeys.key.tr() format for easy_localization');
  print('🎯 Automating the manual JSON key-value creation process');
  print('');

  final detector = HardcodeDetector();
  final jsonManager = JsonManager(projectPath);
  final transformer = CodeTransformer();

  final dartFiles = libDir
      .listSync(recursive: true)
      .where((f) => f.path.endsWith('.dart'))
      .cast<File>();

  var totalStringFound = 0;
  var totalStringProcessed = 0;

  for (final file in dartFiles) {
    final relativePath = p.relative(file.path, from: projectPath);
    print('📄 Processing: $relativePath');

    final hardcodedStrings = await detector.findHardcodedStrings(file);

    if (hardcodedStrings.isEmpty) {
      print('   ✅ No hardcoded strings found');
      continue;
    }

    totalStringFound += hardcodedStrings.length;
    print('   🔍 Found ${hardcodedStrings.length} hardcoded string(s)');

    // Collect replacements for batch processing
    final replacements = <MapEntry<HardcodedStringInfo, String>>[];

    for (final stringInfo in hardcodedStrings) {
      print('');
      print('   📝 Found: "${stringInfo.value}"');
      print('   📍 Line ${stringInfo.line}:${stringInfo.column}');

      // Show context if string is in array or complex expression
      await _showStringContext(stringInfo, file);

      stdout.write('   ❓ Move to localization? (y/n/c for custom key): ');
      final input = stdin.readLineSync()?.toLowerCase();

      if (input == null || input == 'n') {
        print('   ⏭️  Skipped');
        continue;
      }

      String key;
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

      // Check if key already exists
      if (await jsonManager.keyExists(key)) {
        print('   ⚠️  Key "$key" already exists in en.json');
        stdout.write('   ❓ Use different key? (y/n): ');
        final useOther = stdin.readLineSync()?.toLowerCase() == 'y';

        if (useOther) {
          stdout.write('   🔑 Enter new key: ');
          final newKey = stdin.readLineSync();
          if (newKey != null && newKey.isNotEmpty) {
            key = newKey;
          } else {
            print('   ❌ Invalid key, skipping');
            continue;
          }
        } else {
          print('   ⏭️  Skipped due to duplicate key');
          continue;
        }
      }

      // Add to JSON
      await jsonManager.addTranslation(key, stringInfo.value);

      // Add to replacements batch
      replacements.add(MapEntry(stringInfo, key));

      print('   ✅ Added "$key": "${stringInfo.value}" to en.json');
      totalStringProcessed++;
    }

    // Perform batch replacement if there are any replacements
    if (replacements.isNotEmpty) {
      try {
        await transformer.replaceMultipleStrings(file, replacements);
        print('   ✨ Applied ${replacements.length} LocaleKeys.key.tr() replacement(s)');
      } catch (e) {
        print('   ❌ Failed to apply batch replacements: $e');
        print('   🔄 Trying individual replacements...');

        // Fallback to individual replacements
        var successCount = 0;
        for (final replacement in replacements) {
          try {
            await transformer.replaceStringWithLocale(
              file, 
              replacement.key, 
              replacement.value
            );
            print('   ✅ Replaced "${replacement.key.value}" with LocaleKeys.${replacement.value}.tr()');
            successCount++;
          } catch (e) {
            print('   ❌ Failed to replace "${replacement.key.value}": $e');
          }
        }
        if (successCount > 0) {
          print('   ✨ Successfully applied $successCount individual replacement(s)');
        }
      }
    }

    print('');
  }

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
    print('✨ Thanks for using Flutter Hardcode Localizer v1.0.1!');
  }
}

/// Show additional context about where the string is located
Future<void> _showStringContext(HardcodedStringInfo stringInfo, File file) async {
  try {
    final lines = await file.readAsLines();
    final lineIndex = stringInfo.line - 1;

    if (lineIndex >= 0 && lineIndex < lines.length) {
      final line = lines[lineIndex].trim();

      // Check if string appears to be in an array or complex structure
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
    // Ignore context errors, not critical
  }
}

String _truncate(String text, int maxLength) {
  if (text.length <= maxLength) return text;
  return '${text.substring(0, maxLength - 3)}...';
}