import 'dart:io';
import 'package:dart_style/dart_style.dart';
import 'hardcode_detector.dart';

/// CodeTransformer
///
/// Utility for replacing hardcoded strings in Dart source files
/// with `LocaleKeys.key.tr()` calls for seamless easy_localization integration.
/// Can process both single and multiple replacements in code files.
class CodeTransformer {
  // Formatter for Dart code; keeps code clean after replacements
  final DartFormatter _formatter = DartFormatter(languageVersion: DartFormatter.latestLanguageVersion);

  /// Replace a hardcoded string with LocaleKeys.key.tr() for easy_localization
  ///
  /// Finds the specified hardcoded string by offset in [file], replaces it
  /// with the localization reference, and formats the code.
  ///
  /// - [file]: Dart source file to update
  /// - [stringInfo]: Metadata (offset, length, etc.) of the string to replace
  /// - [key]: Localization key for this string
  ///
  /// Handles code formatting errors gracefully: falls back to unformatted code.
  Future<void> replaceStringWithLocale(
    File file,
    HardcodedStringInfo stringInfo,
    String key,
  ) async {
    final content = await file.readAsString();

    // Format string as required by easy_localization: LocaleKeys.key.tr()
    final replacement = 'LocaleKeys.$key.tr()';

    // Replace the hardcoded string using offset/length
    final newContent = content.replaceRange(
      stringInfo.offset,
      stringInfo.offset + stringInfo.length,
      replacement,
    );

    try {
      // Try to reformat the Dart file
      final formattedContent = _formatter.format(newContent);
      await file.writeAsString(formattedContent);
    } catch (e) {
      // If formatting fails, write the raw (unformatted) code
      print('⚠️  Warning: Could not format code, writing unformatted: $e');
      await file.writeAsString(newContent);
    }
  }

  /// Replace multiple strings in a single file efficiently
  ///
  /// Processes all strings found in [replacements] at once.
  /// Sorts by highest offset first to prevent offset corruption.
  ///
  /// - [file]: Dart source file to update
  /// - [replacements]: List of MapEntry(HardcodedStringInfo, key)
  ///
  /// Throws an exception if NO replacements succeed (prevents silent failures).
  Future<void> replaceMultipleStrings(
    File file,
    List<MapEntry<HardcodedStringInfo, String>> replacements,
  ) async {
    final content = await file.readAsString();

    // Descending offset ensures early replacements don't shift later offsets
    final sortedReplacements = replacements.toList()
      ..sort((a, b) => b.key.offset.compareTo(a.key.offset));

    var modifiedContent = content;
    var successCount = 0;

    // Replace each string; catch and log if a failure happens
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

    // Prevent silent mis-transformation if none succeeded
    if (successCount == 0) {
      throw Exception('No string literals were successfully replaced');
    }

    try {
      // Format the final code after all replacements
      final formattedContent = _formatter.format(modifiedContent);
      await file.writeAsString(formattedContent);
    } catch (e) {
      // Always save even if formatting fails
      print('⚠️  Warning: Could not format code, writing unformatted: $e');
      await file.writeAsString(modifiedContent);
    }
  }
}
