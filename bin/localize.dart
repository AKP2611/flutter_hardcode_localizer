#!/usr/bin/env dart

import 'dart:io';
import 'package:flutter_hardcode_localizer/flutter_hardcode_localizer.dart';

void main(List<String> args) async {
  print('🔍 Flutter Hardcode Localizer');
  print('==================================');
  print('🚀 Enhanced for easy_localization package');
  print('✨ Generates LocaleKeys.key.tr() format automatically');
  print('🎯 Removes manual JSON key-value creation process');

  String targetPath = '.';
  if (args.isNotEmpty) {
    targetPath = args.first;
  }

  if (!Directory(targetPath).existsSync()) {
    print('❌ Directory not found: $targetPath');
    exit(1);
  }

  print('📂 Scanning Flutter project at: $targetPath');
  print('');

  try {
    await runLocalizationTool(targetPath);
    print('');
    print('✅ Localization process completed successfully!');
  } catch (e) {
    print('❌ Error: $e');
    exit(1);
  }
}
