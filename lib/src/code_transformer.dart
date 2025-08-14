import 'dart:io';
import 'package:dart_style/dart_style.dart';
import 'hardcode_detector.dart';

class CodeTransformer {
  final DartFormatter _formatter = DartFormatter();

  /// Replace a hardcoded string with LocaleKeys.key.tr() for easy_localization
  Future<void> replaceStringWithLocale(
    File file,
    HardcodedStringInfo stringInfo,
    String key,
  ) async {
    final content = await file.readAsString();

    // Generate LocaleKeys.key.tr() format for easy_localization package
    final replacement = 'LocaleKeys.$key.tr()';

    final newContent = content.replaceRange(
      stringInfo.offset,
      stringInfo.offset + stringInfo.length,
      replacement,
    );

    try {
      // Format the code
      final formattedContent = _formatter.format(newContent);
      await file.writeAsString(formattedContent);
    } catch (e) {
      // If formatting fails, write unformatted
      print('⚠️  Warning: Could not format code, writing unformatted: $e');
      await file.writeAsString(newContent);
    }
  }

  /// Replace multiple strings in a single file efficiently
  Future<void> replaceMultipleStrings(
    File file,
    List<MapEntry<HardcodedStringInfo, String>> replacements,
  ) async {
    final content = await file.readAsString();

    // Sort replacements by offset in descending order to avoid offset issues
    final sortedReplacements = replacements.toList()
      ..sort((a, b) => b.key.offset.compareTo(a.key.offset));

    var modifiedContent = content;
    var successCount = 0;

    // Apply replacements using LocaleKeys.key.tr() format
    for (final replacement in sortedReplacements) {
      final stringInfo = replacement.key;
      final key = replacement.value;

      try {
        modifiedContent = modifiedContent.replaceRange(
          stringInfo.offset,
          stringInfo.offset + stringInfo.length,
          'LocaleKeys.$key.tr()',
        );
        successCount++;
      } catch (e) {
        print('⚠️  Warning: Could not replace "${stringInfo.value}": $e');
      }
    }

    if (successCount == 0) {
      throw Exception('No string literals were successfully replaced');
    }

    try {
      // Format the modified content
      final formattedContent = _formatter.format(modifiedContent);
      await file.writeAsString(formattedContent);
    } catch (e) {
      print('⚠️  Warning: Could not format code, writing unformatted: $e');
      await file.writeAsString(modifiedContent);
    }
  }
}