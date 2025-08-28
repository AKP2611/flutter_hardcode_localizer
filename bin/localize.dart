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
      help: 'Allow automatic approval of suggested JSON keys without requiring developer consent.',
      allowed: ['true', 'false'],
      defaultsTo: 'false',
    )
    ..addOption('skipFiles',
        abbr: 's',
        help: 'Comma-separated list of file paths to skip.',
        valueHelp: 'file1,file2,path/file,...',
        defaultsTo: 'lib/ui/theme/codegen_key.g.dart')
    ..addOption(
      'prefix',
      abbr: 'f',
      help: 'Add [a-z]{2,6} prefix to every json keys.',
      valueHelp: 'prefixSuggestedKey',
      defaultsTo: '',
    )
    ..addOption(
      'languages',
      abbr: 'l',
      help: 'Add json files per languages.',
      valueHelp: 'en,es,hi',
      defaultsTo: 'en',
    );

  final argResults = parser.parse(args);

  // Parse targetPath
  final targetPath = (argResults['targetPath'] != null && argResults['targetPath'].toString().isNotEmpty) == true
      ? argResults['targetPath'] as String
      : '.';

  // Parse autoApproveSuggestedKeys
  final autoApproveSuggestedKeys = ((argResults['autoApproveSuggestedKeys'] != null &&
              argResults['autoApproveSuggestedKeys'].toString().isNotEmpty) ==
          true)
      ? (argResults['autoApproveSuggestedKeys'] == 'true')
      : false;

  // Parse the comma-separated skipFiles into a List<String>
  final skipFilesString = ((argResults['skipFiles'] != null && argResults['skipFiles'].toString().isNotEmpty) == true)
      ? argResults['skipFiles'] as String
      : '';
  final skipFiles = skipFilesString.isEmpty
      ? <String>[]
      : skipFilesString.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toSet().toList();

  if (!skipFiles.contains('lib/ui/theme/codegen_key.g.dart')) {
    skipFiles.add('lib/ui/theme/codegen_key.g.dart');
  }

  // Parse prefix which will be appended to suggested json key
  final String prefix = (argResults['prefix'] != null && argResults['prefix'].toString().isNotEmpty) == true
      ? argResults['prefix'] as String
      : '';

  // Parse the comma-separated skipFiles into a List<String>
  final languagesString = ((argResults['languages'] != null && argResults['languages'].toString().isNotEmpty) == true)
      ? argResults['languages'] as String
      : '';
  final languages = languagesString.isEmpty
      ? <String>[]
      : languagesString
          .split(',')
          .map((s) => s.trim().toLowerCase())
          .where((s) => s.isNotEmpty && s.length > 1)
          .toSet()
          .toList();

  if (!languages.contains('en')) {
    languages.add('en');
  }
  languages.sort((a, b) => a.compareTo(b));

  print('   Target Path: $targetPath');
  print('   Files to skip: $skipFiles');
  print('   Auto Approve Suggested Keys: $autoApproveSuggestedKeys');
  print('   prefix: $prefix');
  print('   languages: $languages');
  print('   ');

  if (!Directory(targetPath).existsSync()) {
    print('❌ Directory not found: $targetPath');
    exit(1);
  }

  if (prefix.isNotEmpty && !RegExp(r'^[a-z]{2,6}$').hasMatch(prefix)) {
    print('❌ Prefix must follow: [a-z]{2,6}');
    exit(1);
  }

  print('📂 Scanning Flutter project at: $targetPath');
  print('');

  try {
    await runLocalizationTool(
        args: AdditionalRunArguments(
      targetPath: targetPath,
      skipFiles: skipFiles,
      autoApproveSuggestedKeys: autoApproveSuggestedKeys,
      prefix: prefix,
      languages: languages,
    ));
    print('');
    print('✅ Localization process completed successfully!');
  } catch (e) {
    print('❌ Error: $e');
    exit(1);
  }
}
