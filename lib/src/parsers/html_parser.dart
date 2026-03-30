import 'package:html/parser.dart' as html_parser;

import '../searchlight_parsedoc_base.dart';
import 'dom_block_parser.dart';

Future<ParsedDocument> parseHtmlString(
  String source, {
  ParseOptions options = const ParseOptions(),
}) async {
  if (source.trim().isEmpty) {
    return const ParsedDocument(format: ParsedFormat.html);
  }

  final document = html_parser.parse(source);
  final blocks = extractBlocks(document.nodes, options: options);
  final title = normalizeWhitespace(document.querySelector('title')?.text ?? '');

  return ParsedDocument(
    format: ParsedFormat.html,
    title: title.isEmpty ? null : title,
    blocks: blocks,
  );
}
