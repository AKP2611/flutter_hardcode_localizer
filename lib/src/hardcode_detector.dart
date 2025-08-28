import 'dart:io';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'string_utils.dart';

/// Metadata for a detected hardcoded string within Dart code.
///
/// - [value]: The actual string literal content.
/// - [offset]: Byte offset within the source file (for replacements).
/// - [length]: Length of the string literal in source code.
/// - [line],[column]: Source position for reporting/messages.
/// - [suggestedKey]: CamelCase key suggested for localization.
class HardcodedStringInfo {
  final String value;
  final int offset;
  final int length;
  final int line;
  final int column;
  final String suggestedKey;

  HardcodedStringInfo({
    required this.value,
    required this.offset,
    required this.length,
    required this.line,
    required this.column,
    required this.suggestedKey,
  });
}

/// Detector to find hardcoded string literals in Dart source files.
///
/// Uses Dart AST parsing to reliably extract string literals
/// suitable for localization; skips those that look like assets, URLs, etc.
class HardcodeDetector {
  /// Find all hardcoded strings in a Dart file, returning detailed info
  /// for each string suitable for automatic replacement.
  ///
  /// [file]: Dart source file to scan
  /// Returns: List of [HardcodedStringInfo] for each real hardcoded string.
  Future<List<HardcodedStringInfo>> findHardcodedStrings(File file) async {
    // Read the file source
    final source = await file.readAsString();
    // Parse source into Dart AST
    final parseResult = parseString(content: source);

    // If there are parsing errors, abort scan
    if (parseResult.errors.isNotEmpty) {
      return [];
    }

    // Instantiate visitor with source code context
    final visitor = _StringLiteralVisitor(source);
    // Traverse the AST to collect string literals
    parseResult.unit.accept(visitor);

    // Return all gathered hardcoded strings
    return visitor.hardcodedStrings;
  }
}

/// AST Visitor to collect hardcoded string literals (excluding assets, URLs, etc.)
class _StringLiteralVisitor extends RecursiveAstVisitor<void> {
  final String sourceCode;
  final List<HardcodedStringInfo> hardcodedStrings = [];

  _StringLiteralVisitor(this.sourceCode);

  /// Visits [ImportDirective] AST nodes (standard package and file imports in Dart).
  ///
  /// It will be skipped in localisation process.
  @override
  void visitImportDirective(ImportDirective node) {
    return;
  }

  /// Visits [Annotation] AST nodes (annotations in Dart).
  ///
  /// It will be skipped in localisation process.
  @override
  void visitAnnotation(Annotation node) {
    return;
  }

  /// Visits [AssertStatement] AST nodes (Assert Statements in Dart).
  ///
  /// It will be skipped in localisation process.
  @override
  void visitAssertStatement(AssertStatement node) {
    return;
  }

  /// Visits [SwitchPatternCase] AST nodes (Switch Case Statements in Dart).
  ///
  /// It will be skipped in localisation process.
  @override
  void visitSwitchPatternCase(SwitchPatternCase node) {
    return;
  }

  /// Visits [SwitchPatternCase] AST nodes (Switch Case Statements in Dart).
  ///
  /// It will be skipped in localisation process.
  @override
  void visitIfStatement(IfStatement node) {
    return;
  }

  /// Visits [MethodInvocation] AST nodes (Search for print statements in method).
  ///
  /// It will be skipped in localisation process if text is in print statements.
  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name == 'print' && node.target == null) {
      return;
    }
    super.visitMethodInvocation(node);
  }

  /// Visits [SimpleStringLiteral] AST nodes (standard string literals in Dart).
  ///
  /// Skips literals that are empty, just one char, or look like assets/URLs.
  /// Creates [HardcodedStringInfo] for each literal found.
  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    final value = node.value;

    // Skip ignored types of string literals (configured below)
    if (_shouldSkipString(value)) {
      return;
    }

    // Get line/column info for the literal's offset
    final lineInfo = parseString(content: sourceCode).lineInfo;
    final location = lineInfo.getLocation(node.offset);

    // Construct info, including suggested key for localization
    hardcodedStrings.add(HardcodedStringInfo(
      value: value,
      offset: node.offset,
      length: node.length,
      line: location.lineNumber,
      column: location.columnNumber,
      suggestedKey: StringUtils.generateKey(value),
    ));

    // Continue standard visitor traversal
    super.visitSimpleStringLiteral(node);
  }

  /// Predicate to decide if a string should be ignored/skipped.
  ///
  /// - Empty or whitespace-only strings
  /// - Single-character strings
  /// - URLs and asset references
  /// - Anything that looks like a file/resource path
  bool _shouldSkipString(String value) {
    if (value.trim().isEmpty) return true;
    if (value.length == 1) return true;
    if (value.startsWith('http')) return true;
    if (value.startsWith('assets/')) return true;
    if (value.contains('/') && value.contains('.')) return true;
    return false;
  }
}
