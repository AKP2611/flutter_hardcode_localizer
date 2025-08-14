import 'dart:io';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'string_utils.dart';

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

class HardcodeDetector {
  /// Find all hardcoded strings in a Dart file
  Future<List<HardcodedStringInfo>> findHardcodedStrings(File file) async {
    final source = await file.readAsString();
    final parseResult = parseString(content: source);

    if (parseResult.errors.isNotEmpty) {
      return [];
    }

    final visitor = _StringLiteralVisitor(source);
    parseResult.unit.accept(visitor);

    return visitor.hardcodedStrings;
  }
}

class _StringLiteralVisitor extends RecursiveAstVisitor<void> {
  final String sourceCode;
  final List<HardcodedStringInfo> hardcodedStrings = [];

  _StringLiteralVisitor(this.sourceCode);

  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    final value = node.value;

    if (_shouldSkipString(value)) {
      return;
    }

    final lineInfo = parseString(content: sourceCode).lineInfo;
    final location = lineInfo.getLocation(node.offset);

    hardcodedStrings.add(HardcodedStringInfo(
      value: value,
      offset: node.offset,
      length: node.length,
      line: location.lineNumber,
      column: location.columnNumber,
      suggestedKey: StringUtils.generateKey(value),
    ));

    super.visitSimpleStringLiteral(node);
  }

  bool _shouldSkipString(String value) {
    if (value.trim().isEmpty) return true;
    if (value.length == 1) return true;
    if (value.startsWith('http')) return true;
    if (value.startsWith('assets/')) return true;
    if (value.contains('/') && value.contains('.')) return true;
    return false;
  }
}