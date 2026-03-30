import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;

import '../searchlight_parsedoc_base.dart';

List<ParsedBlock> extractBlocks(
  Iterable<Node> nodes, {
  ParseOptions options = const ParseOptions(),
}) {
  final blocks = <ParsedBlock>[];

  for (final (index, node) in nodes.indexed) {
    _visitNode(
      node,
      path: 'root[$index]',
      blocks: blocks,
      options: options,
    );
  }

  return switch (options.mergeStrategy) {
    MergeStrategy.split => blocks,
    MergeStrategy.merge => _mergeBlocks(blocks),
    MergeStrategy.both => _mergeBlocksBoth(blocks),
  };
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
  required ParseOptions options,
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

  final original = ParsedNode(
    tag: node.localName ?? 'element',
    text: normalizeWhitespace(node.text),
    rawMarkup: node.outerHtml,
    attributes: Map<String, String>.unmodifiable(node.attributes),
  );
  final transformed = options.transform?.call(original, options.context) ?? original;

  if (transformed.rawMarkup != original.rawMarkup) {
    final fragment = html_parser.parseFragment(transformed.rawMarkup);
    if (fragment.nodes.length == 1) {
      _visitNode(
        fragment.nodes.single,
        path: path,
        blocks: blocks,
        options: options,
      );
      return;
    }

    for (final (index, child) in fragment.nodes.indexed) {
      _visitNode(
        child,
        path: '$path.raw[$index]',
        blocks: blocks,
        options: options,
      );
    }
    return;
  }

  if (transformed.tag != original.tag ||
      transformed.text != original.text ||
      !_sameAttributes(transformed.attributes, original.attributes)) {
    final text = normalizeWhitespace(transformed.text);
    if (text.isNotEmpty) {
      blocks.add(
        ParsedBlock(
          tag: transformed.tag,
          text: text,
          path: path,
          attributes: Map<String, String>.unmodifiable(transformed.attributes),
        ),
      );
    }
    return;
  }

  for (final (index, child) in node.nodes.indexed) {
    _visitNode(
      child,
      path: '$path.${node.localName}[$index]',
      blocks: blocks,
      options: options,
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

bool _sameAttributes(Map<String, String> left, Map<String, String> right) {
  if (left.length != right.length) {
    return false;
  }

  for (final entry in left.entries) {
    if (right[entry.key] != entry.value) {
      return false;
    }
  }

  return true;
}

List<ParsedBlock> _mergeBlocks(List<ParsedBlock> blocks) {
  final merged = <ParsedBlock>[];

  for (final block in blocks) {
    if (merged.isNotEmpty && _canMerge(merged.last, block)) {
      final previous = merged.removeLast();
      merged.add(_combineBlocks(previous, block));
      continue;
    }

    merged.add(block);
  }

  return merged;
}

List<ParsedBlock> _mergeBlocksBoth(List<ParsedBlock> blocks) {
  final merged = <ParsedBlock>[];

  for (final block in blocks) {
    if (merged.isNotEmpty && _canMerge(merged.last, block)) {
      final aggregate = merged.removeLast();
      merged.insert(merged.length, block);
      merged.add(_combineBlocks(aggregate, block));
      continue;
    }

    merged
      ..add(block)
      ..add(block.copyWith());
  }

  return merged;
}

bool _canMerge(ParsedBlock left, ParsedBlock right) {
  return left.tag == right.tag &&
      _pathWithoutLastIndex(left.path) == _pathWithoutLastIndex(right.path);
}

String _pathWithoutLastIndex(String path) {
  final bracket = path.lastIndexOf('[');
  if (bracket == -1) {
    return path;
  }

  return path.substring(0, bracket);
}

ParsedBlock _combineBlocks(ParsedBlock left, ParsedBlock right) {
  return ParsedBlock(
    tag: left.tag,
    text: '${left.text} ${right.text}',
    path: left.path,
    attributes: {
      ...right.attributes,
      ...left.attributes,
    },
  );
}
