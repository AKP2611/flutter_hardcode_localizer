# Changelog

## [1.0.5] - 2025-08-19
#### 🐞Unnecessary localisation of dart statements will be ignored
- ✅ Import Statements [ import 'widgets/sample_widget.dart';  import 'dart:io'; import 'string_utils.dart'; & so on]
- ✅ Assertions [test cases assertions will be skipped]
- ✅ Annotations [any type of annotations used by flutter/dart plugins/packages]

## [1.0.4] - 2025-08-18

### 🎉New Tool features added 
#### additional optional arguments added for CLI tool
```bash
dart run flutter_hardcode_localizer:localize \
  --targetPath example \
  --skipFiles lib/widgets/skip_file_1.dart,lib/widgets/skip_file_2.dart  \
  --autoApproveSuggestedKeys true
  
--targetPath
(Optional) Path to your project’s target directory.

--autoApproveSuggestedKeys
(Optional, true/false) Automatically approve suggested JSON keys without developer consent.

--skipFiles
(Optional) Comma-separated list of file paths to skip during processing.

lib/ui/theme/codegen_key.g.dart will be skipped automatically, no need to manually add this in skipFiles array  
```

## [1.0.3] - 2025-08-18

### 🎉Reviewed Pub.dev Analysis
#### New Features
- ✅ Added Example
- ✅ Platform support constraints updated
- ✅ Developer Comments added for classes

## [1.0.2] - 2025-08-14

### 🎉Repository Licence updated

## [1.0.1] - 2025-08-14

### 🚀 Enhanced for easy_localization Integration

#### New Features
- ✅ **LocaleKeys.key.tr() Format**: Changed replacement format from `Locale.$key` to `LocaleKeys.$key.tr()`
- ✅ **easy_localization Workflow**: Perfect integration with the popular easy_localization package
- ✅ **Automated JSON Key-Value Creation**: Eliminates manual process of adding translations
- ✅ **Standard Directory Structure**: Uses `assets/languages/` following easy_localization conventions
- ✅ **Enhanced Documentation**: Added specific command for LocaleKeys generation with correct parameters

#### Technical Changes
- **JsonManager**: Updated to use `assets/languages/en.json` instead of `lang/en.json`
- **Path Standardization**: Follows easy_localization standard directory structure
- **pubspec.yaml Integration**: Clear instructions for adding assets directory

#### Enhanced Command Reference
The README now includes the specific command for generating LocaleKeys:
```bash
dart run easy_localization:generate --source-dir assets/languages/ -f keys -O lib/ui/theme -o codegen_key.g.dart
```

#### Important Setup Note
Added crucial pubspec.yaml configuration requirement:
```yaml
flutter:
  assets:
    - assets/languages/
```

#### Why This Update?
This version specifically addresses the **tedious manual process** of setting up easy_localization:

**Before v1.0.1 (Manual Process):**
1. ❌ Manually find all hardcoded strings
2. ❌ Manually add each to assets/languages/en.json  
3. ❌ Manually replace each in code with LocaleKeys.key.tr()
4. ❌ Manually run code generation with correct parameters
5. ❌ Manually configure pubspec.yaml

**After v1.0.1 (Automated):**
1. ✅ Add `assets/languages/` to pubspec.yaml
2. ✅ Run: `dart run flutter_hardcode_localizer:localize`
3. ✅ Run: `dart run easy_localization:generate --source-dir assets/languages/ -f keys -O lib/ui/theme -o codegen_key.g.dart`
4. ✅ Add import and test!

## [1.0.0] - 2025-08-14

### 🎉 Initial Stable Release

- ✅ Smart hardcoded string detection
- ✅ Interactive CLI with user prompts
- ✅ Automatic JSON key generation  
- ✅ Reliable code transformation
- ✅ Support for arrays, methods, constructors, maps
- ✅ Comprehensive test coverage
- ✅ Production-ready stability