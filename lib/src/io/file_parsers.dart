import 'dart:io';

import '../searchlight_parsedoc_base.dart';

class UnsupportedParsedocFileTypeError extends Error {
  UnsupportedParsedocFileTypeError(this.path);

  final String path;

  @override
  String toString() {
    return 'UnsupportedParsedocFileTypeError: unsupported file type for "$path".';
  }
}

Future<ParsedDocument> parseFile(
  String path, {
  ParseOptions options = const ParseOptions(),
}) async {
  final extension = _normalizedExtension(path);

  return switch (extension) {
    '.md' || '.markdown' => parseMarkdownFile(path, options: options),
    '.html' || '.htm' => parseHtmlFile(path, options: options),
    _ => throw UnsupportedParsedocFileTypeError(path),
  };
}

Future<ParsedDocument> parseMarkdownFile(
  String path, {
  ParseOptions options = const ParseOptions(),
}) async {
  final source = await File(path).readAsString();
  final document = await parseMarkdownString(source, options: options);
  return ParsedDocument(
    format: document.format,
    sourcePath: path,
    title: document.title,
    blocks: document.blocks,
  );
}

Future<ParsedDocument> parseHtmlFile(
  String path, {
  ParseOptions options = const ParseOptions(),
}) async {
  final source = await File(path).readAsString();
  final document = await parseHtmlString(source, options: options);
  return ParsedDocument(
    format: document.format,
    sourcePath: path,
    title: document.title,
    blocks: document.blocks,
  );
}

String _normalizedExtension(String path) {
  final dotIndex = path.lastIndexOf('.');
  if (dotIndex == -1) {
    return '';
  }

  return path.substring(dotIndex).toLowerCase();
}
