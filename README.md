# Flutter Hardcode Localizer CLI Utility

🚀 **Enhanced for easy_localization** - Automate the tedious process of manually adding JSON key-values for Flutter localization by CLI Utility!

## 🎯 **Perfect Companion for easy_localization Package**

This tool **eliminates the manual process** of:
1. ❌ Manually creating JSON key-value pairs
2. ❌ Manually replacing strings in code  
3. ❌ Manually running code generation
4. ❌ Manual import management

Instead, it **automates everything**:
1. ✅ **Finds hardcoded strings** in your Flutter project
2. ✅ **Automatically adds them to en.json** with smart key generation
3. ✅ **Replaces strings with LocaleKeys.key.tr()** format
4. ✅ **Works with arrays, methods, constructors, maps** seamlessly
5. ✅ Skips **every type of import statements, assertions and annotations**

## 🔄 **What It Does**

### **Before (Manual Process):**
```dart
// 1. You have hardcoded strings
Text('Hello World')
final items = ['Save', 'Cancel', 'Delete'];

// 2. You manually add to assets/languages/en.json:
{
  "helloWorld": "Hello World",
  "save": "Save", 
  "cancel": "Cancel",
  "delete": "Delete"
}

// 3. You manually replace in code:
Text(LocaleKeys.helloWorld.tr())
final items = [LocaleKeys.save.tr(), LocaleKeys.cancel.tr(), LocaleKeys.delete.tr()];

// 4. You manually run: flutter packages pub run easy_localization:generate
```

### **After (Automated with running CLI utility):**
```bash
# Just run this tool:
dart run flutter_hardcode_localizer:localize

# It automatically:
# ✅ Finds all hardcoded strings
# ✅ Adds them to assets/languages/en.json  
# ✅ Replaces with LocaleKeys.key.tr()
# ✅ Shows you next steps
```

## 🎨 **What Gets Generated**

### ✅ **Arrays/Lists**
```dart
// Before
final items = ['Hello', 'World', 'Flutter'];

// After  
final items = [LocaleKeys.hello.tr(), LocaleKeys.world.tr(), LocaleKeys.flutter.tr()];
```

### ✅ **Method Arguments**
```dart
// Before
Text('Click me')
ElevatedButton(child: Text('Submit'))

// After
Text(LocaleKeys.clickMe.tr())
ElevatedButton(child: Text(LocaleKeys.submit.tr()))
```

### ✅ **Constructor Parameters**
```dart
// Before
MaterialApp(
  title: 'My App',
  home: Scaffold(...)
)

// After
MaterialApp(
  title: LocaleKeys.myApp.tr(),
  home: Scaffold(...)
)
```

## 🚀 **Installation & Usage**

### **Prerequisites**
Make sure you have `easy_localization` already set up in your project.

### **Install Tool**
```yaml
dev_dependencies:
  flutter_hardcode_localizer: ^latest_version
```

### **Run Tool**
```bash
# On current directory
dart run flutter_hardcode_localizer:localize 

# With arguments including features 
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

## 📋 **Complete easy_localization Workflow**

1. **Setup easy_localization** in your project (if not already done)

2. **Add assets directory to pubspec.yaml**:
```yaml
flutter:
  assets:
    - assets/languages/
```

3. **Run this tool**: `dart run flutter_hardcode_localizer:localize`

4. **Generate LocaleKeys**: Use the following command to generate LocaleKeys class:

```bash
dart run easy_localization:generate --source-dir assets/languages/ -f keys -O lib/ui/theme -o codegen_key.g.dart
```

5. **Add import**: `import "lib/ui/theme/codegen_key.g.dart";`

6. **Test your app** - all strings now use proper localization!

> **📝 Important Notes**:
> - The tool creates JSON files in `assets/languages/` directory
> - **You must add `assets/languages/` to your `pubspec.yaml` under flutter > assets**
> - The generation command parameters:
>   - `--source-dir assets/languages/` - Specifies where your translation files are located
>   - `-f keys` - Generate only keys format (not classes)
>   - `-O lib/ui/theme` - Output directory for generated files
>   - `-o codegen_key.g.dart` - Custom filename for the generated file
>
> **Alternative**: You can also use the basic command: `flutter packages pub run easy_localization:generate`

## 🎯 **Why This Tool?**

### **Problem with Manual easy_localization Setup:**
- 😫 **Tedious**: Manually find all hardcoded strings
- 😫 **Error-Prone**: Miss strings or create wrong keys
- 😫 **Time-Consuming**: Large projects take hours
- 😫 **Inconsistent**: Different key naming conventions

### **Solution with This Tool:**
- 🎉 **Automated**: Finds all strings automatically
- 🎉 **Accurate**: Uses AST parsing for 100% coverage  
- 🎉 **Fast**: Process entire projects in minutes
- 🎉 **Consistent**: Smart camelCase key generation

## 🛠️ **Technical Features**

- **Smart Detection**: Skips URLs, file paths, constants automatically
- **Context Awareness**: Shows where strings are found (arrays, methods, etc.)
- **Batch Processing**: Handles multiple strings per file efficiently
- **Error Handling**: Graceful fallbacks and comprehensive error reporting
- **Code Formatting**: Maintains proper Dart code formatting
- **Standard Path**: Uses `assets/languages/` following easy_localization conventions

## 🎉 **Benefits**

- ✅ **Saves Hours**: No more manual string hunting
- ✅ **Reduces Errors**: Automated process prevents mistakes
- ✅ **Consistent Naming**: Smart key generation
- ✅ **Works with Complex Code**: Arrays, methods, constructors, maps
- ✅ **Perfect Integration**: Designed specifically for easy_localization
- ✅ **Standard Directory Structure**: Uses conventional `assets/languages/` path

## 📝 **License**

MIT License - Perfect for both personal and commercial projects.

---

**Made with ❤️ for Flutter developers using easy_localization**

*Automate the boring stuff, focus on building great apps!*