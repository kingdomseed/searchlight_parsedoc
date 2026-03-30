import 'package:html/parser.dart' as html_parser;
import 'package:markdown/markdown.dart' as markdown;

import '../searchlight_parsedoc_base.dart';
import 'dom_block_parser.dart';

Future<ParsedDocument> parseMarkdownString(
  String source, {
  ParseOptions options = const ParseOptions(),
}) async {
  if (source.trim().isEmpty) {
    return const ParsedDocument(format: ParsedFormat.markdown);
  }

  final renderedHtml = markdown.markdownToHtml(source);
  final fragment = html_parser.parseFragment(renderedHtml);
  final blocks = extractBlocks(fragment.nodes, options: options);

  return ParsedDocument(
    format: ParsedFormat.markdown,
    title: findFirstBlockText(blocks, tag: 'h1'),
    blocks: blocks,
  );
}
