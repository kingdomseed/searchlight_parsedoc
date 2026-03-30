import 'package:html/parser.dart' as html_parser;

import '../models/parsed_document.dart';
import 'dom_block_parser.dart';

Future<ParsedDocument> parseHtmlString(String source) async {
  if (source.trim().isEmpty) {
    return const ParsedDocument(format: ParsedFormat.html);
  }

  final document = html_parser.parse(source);
  final blocks = extractBlocks(document.nodes);
  final title = normalizeWhitespace(document.querySelector('title')?.text ?? '');

  return ParsedDocument(
    format: ParsedFormat.html,
    title: title.isEmpty ? null : title,
    blocks: blocks,
  );
}
