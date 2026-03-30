import 'package:html/dom.dart';

import '../models/parsed_document.dart';

List<ParsedBlock> extractBlocks(Iterable<Node> nodes) {
  final blocks = <ParsedBlock>[];

  for (final (index, node) in nodes.indexed) {
    _visitNode(node, path: 'root[$index]', blocks: blocks);
  }

  return blocks;
}

String? findFirstBlockText(
  List<ParsedBlock> blocks, {
  required String tag,
}) {
  for (final block in blocks) {
    if (block.tag == tag && block.text.isNotEmpty) {
      return block.text;
    }
  }

  return null;
}

String normalizeWhitespace(String value) {
  return value.replaceAll(RegExp(r'\s+'), ' ').trim();
}

void _visitNode(
  Node node, {
  required String path,
  required List<ParsedBlock> blocks,
}) {
  if (node is Text) {
    final text = normalizeWhitespace(node.text);
    final parent = node.parent;
    if (text.isEmpty || parent is! Element) {
      return;
    }

    blocks.add(
      ParsedBlock(
        tag: parent.localName ?? 'text',
        text: text,
        path: _parentPath(path),
        attributes: Map<String, String>.unmodifiable(parent.attributes),
      ),
    );
    return;
  }

  if (node is! Element) {
    return;
  }

  for (final (index, child) in node.nodes.indexed) {
    _visitNode(
      child,
      path: '$path.${node.localName}[$index]',
      blocks: blocks,
    );
  }
}

String _parentPath(String path) {
  final separatorIndex = path.lastIndexOf('.');
  if (separatorIndex == -1) {
    return path;
  }

  return path.substring(0, separatorIndex);
}
