#!/usr/bin/env dart

import 'dart:io';
import 'package:flutter_hardcode_localizer/flutter_hardcode_localizer.dart';
import 'package:args/args.dart';

void main(List<String> args) async {
  print('🔍 Flutter Hardcode Localizer');
  print('==================================');
  print('🚀 Enhanced for easy_localization package');
  print('✨ Generates LocaleKeys.key.tr() format automatically');
  print('🎯 Removes manual JSON key-value creation process');

  final parser = ArgParser()
    ..addOption(
      'targetPath',
      abbr: 'p',
      help: 'The target path for the project.',
    )
    ..addOption(
      'autoApproveSuggestedKeys',
      abbr: 'a',
      help:
          'Allow automatic approval of suggested JSON keys without requiring developer consent.',
      allowed: ['true', 'false'],
      defaultsTo: 'false',
    )
    ..addOption(
      'skipFiles',
      abbr: 's',
      help: 'Comma-separated list of file paths to skip.',
      valueHelp: 'file1,file2,path/file,...',
      defaultsTo: 'lib/ui/theme/codegen_key.g.dart',
    );

  final argResults = parser.parse(args);

  final targetPath = (argResults['targetPath'] != null &&
              argResults['targetPath'].toString().isNotEmpty) ==
          true
      ? argResults['targetPath'] as String
      : '.';

  // Parse string to bool
  final autoApproveSuggestedKeys =
      (argResults['autoApproveSuggestedKeys'] == 'true');

  // Parse the comma-separated string into a List<String>
  final skipFilesRaw = argResults['skipFiles'] as String;
  final skipFiles = skipFilesRaw.isEmpty
      ? <String>[]
      : skipFilesRaw
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

  print('   Target Path: $targetPath');
  print('   Files to skip: $skipFiles');
  print('   Auto Approve Suggested Keys: $autoApproveSuggestedKeys');

  if (!Directory(targetPath).existsSync()) {
    print('❌ Directory not found: $targetPath');
    exit(1);
  }

  print('📂 Scanning Flutter project at: $targetPath');
  print('');

  try {
    await runLocalizationTool(targetPath, autoApproveSuggestedKeys, skipFiles);
    print('');
    print('✅ Localization process completed successfully!');
  } catch (e) {
    print('❌ Error: $e');
    exit(1);
  }
}
