import 'dart:convert';

import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:markdown/markdown.dart' as markdown;
import 'package:searchlight/searchlight.dart';

import '../api/populate_options.dart';
import '../models/merge_strategy.dart';

Future<List<DefaultSchemaElement>> parseParsedocData(
  Object data,
  String fileType, {
  PopulateOptions options = const PopulateOptions(),
}) async {
  final source = _coerceSource(data);

  return switch (fileType) {
    'html' => _extractRecords(
        html_parser.parseFragment(source).nodes,
        options: options,
      ),
    'md' => _extractRecords(
        html_parser
            .parse('<html><head></head><body>${markdown.markdownToHtml(source)}</body></html>')
            .nodes,
        options: options,
      ),
    _ => throw ArgumentError.value(
        fileType,
        'fileType',
        'Supported values are "html" and "md".',
      ),
  };
}

Future<List<String>> populateSearchlight(
  Searchlight db,
  Object data,
  String fileType, {
  PopulateOptions options = const PopulateOptions(),
}) async {
  final records = await parseParsedocData(
    data,
    fileType,
    options: options,
  );
  return db.insertMultiple(records);
}

String _coerceSource(Object data) {
  if (data is String) {
    return data;
  }
  if (data is List<int>) {
    return utf8.decode(data);
  }

  throw ArgumentError.value(
    data,
    'data',
    'Supported values are String and List<int>.',
  );
}

List<DefaultSchemaElement> _extractRecords(
  Iterable<Node> nodes, {
  required PopulateOptions options,
}) {
  final records = <DefaultSchemaElement>[];

  for (final (index, node) in nodes.indexed) {
    final converted = _toVisitedNode(node);
    if (converted == null) {
      continue;
    }

    _visitNode(
        converted,
        parent: null,
        path: '${options.basePath ?? ''}root[$index]',
        records: records,
        options: options,
        context: Map<String, Object?>.from(options.context),
      );
  }

  return records;
}

void _visitNode(
  _VisitedNode node, {
  required _VisitedElement? parent,
  required String path,
  required List<DefaultSchemaElement> records,
  required PopulateOptions options,
  required PopulateFnContext context,
}) {
  switch (node) {
    case _VisitedText(:final text):
      final normalized = _normalizeWhitespace(text);
      if (normalized.isEmpty || parent == null) {
        return;
      }

      _addRecord(
        content: normalized,
        type: parent.tag,
        path: path,
        properties: parent.properties,
        records: records,
        mergeStrategy: options.mergeStrategy,
      );
    case _VisitedElement():
      final transformed = options.transformFn == null
          ? node
          : _applyTransform(node, options.transformFn!, context);

      for (final (index, child) in transformed.children.indexed) {
        _visitNode(
          child,
          parent: transformed,
          path: '$path.${transformed.tag}[$index]',
          records: records,
          options: options,
          context: context,
        );
      }
  }
}

_VisitedElement _applyTransform(
  _VisitedElement node,
  TransformFn transformFn,
  PopulateFnContext context,
) {
  final prepared = NodeContent(
    tag: node.tag,
    raw: node.raw,
    content: node.content,
    properties: node.properties,
  );
  final transformed = transformFn(prepared, context);

  if (transformed.raw != prepared.raw) {
    final fragment = html_parser.parseFragment(transformed.raw);
    final replacement = fragment.nodes.isEmpty
        ? null
        : _toVisitedNode(fragment.nodes.first);
    final additionalProperties = transformed.additionalProperties;

    if (replacement case _VisitedElement()) {
      return replacement.copyWith(
        properties: {
          ...replacement.properties,
          ...?additionalProperties,
        },
      );
    }

    return _VisitedElement(
      tag: transformed.tag,
      raw: transformed.raw,
      content: transformed.content,
      properties: {
        ...?transformed.properties,
        ...?additionalProperties,
      },
      children: <_VisitedNode>[
        _VisitedText(transformed.content),
      ],
    );
  }

  final contentChanged = transformed.content != prepared.content;
  return _VisitedElement(
    tag: transformed.tag,
    raw: transformed.raw,
    content: transformed.content,
    properties: {
      ...?transformed.properties,
      ...?transformed.additionalProperties,
    },
    children: contentChanged ? [_VisitedText(transformed.content)] : node.children,
  );
}

void _addRecord({
  required String content,
  required String type,
  required String path,
  required Map<String, Object?>? properties,
  required List<DefaultSchemaElement> records,
  required MergeStrategy mergeStrategy,
}) {
  final parentPath = path.substring(0, path.lastIndexOf('.'));
  final newRecord = <String, Object?>{
    'type': type,
    'content': content,
    'path': parentPath,
  };
  if (properties != null) {
    newRecord['properties'] = properties;
  }

  switch (mergeStrategy) {
    case MergeStrategy.merge:
      if (!_isMergeable(parentPath, type, records)) {
        records.add(newRecord);
        return;
      }
      _addContentToLastRecord(records, content, properties);
    case MergeStrategy.split:
      records.add(newRecord);
    case MergeStrategy.both:
      if (!_isMergeable(parentPath, type, records)) {
        records
          ..add(newRecord)
          ..add(Map<String, Object?>.from(newRecord));
        return;
      }
      records.insert(records.length - 1, newRecord);
      _addContentToLastRecord(records, content, properties);
  }
}

bool _isMergeable(
  String path,
  String tag,
  List<DefaultSchemaElement> records,
) {
  if (records.isEmpty) {
    return false;
  }

  final lastRecord = records.last;
  final lastPath = lastRecord['path'] as String?;
  final lastTag = lastRecord['type'] as String?;
  if (lastPath == null || lastTag == null) {
    return false;
  }

  return _pathWithoutLastIndex(path) == _pathWithoutLastIndex(lastPath) &&
      tag == lastTag;
}

String _pathWithoutLastIndex(String path) {
  final bracketIndex = path.lastIndexOf('[');
  if (bracketIndex == -1) {
    return path;
  }

  return path.substring(0, bracketIndex);
}

void _addContentToLastRecord(
  List<DefaultSchemaElement> records,
  String content,
  Map<String, Object?>? properties,
) {
  final lastRecord = records.last;
  final lastContent = lastRecord['content'] as String? ?? '';
  lastRecord['content'] = '$lastContent $content'.trim();
  final previousProperties =
      lastRecord['properties'] as Map<String, Object?>? ?? const <String, Object?>{};
  if (properties != null || previousProperties.isNotEmpty) {
    lastRecord['properties'] = {
      ...?properties,
      ...previousProperties,
    };
  }
}

String _normalizeWhitespace(String value) {
  return value.replaceAll(RegExp(r'\s+'), ' ').trim();
}

_VisitedNode? _toVisitedNode(Node node) {
  if (node is Text) {
    return _VisitedText(node.text);
  }
  if (node is! Element) {
    return null;
  }

  final children = <_VisitedNode>[];
  for (final child in node.nodes) {
    final converted = _toVisitedNode(child);
    if (converted != null) {
      children.add(converted);
    }
  }

  return _VisitedElement(
    tag: node.localName ?? 'element',
    raw: node.outerHtml,
    content: _normalizeWhitespace(node.text),
    properties: {
      for (final entry in node.attributes.entries)
        entry.key.toString(): entry.value.toString(),
    },
    children: children,
  );
}

sealed class _VisitedNode {
  const _VisitedNode();
}

final class _VisitedText extends _VisitedNode {
  const _VisitedText(this.text);

  final String text;
}

final class _VisitedElement extends _VisitedNode {
  const _VisitedElement({
    required this.tag,
    required this.raw,
    required this.content,
    required this.properties,
    required this.children,
  });

  final String tag;
  final String raw;
  final String content;
  final Map<String, Object?> properties;
  final List<_VisitedNode> children;

  _VisitedElement copyWith({
    String? tag,
    String? raw,
    String? content,
    Map<String, Object?>? properties,
    List<_VisitedNode>? children,
  }) {
    return _VisitedElement(
      tag: tag ?? this.tag,
      raw: raw ?? this.raw,
      content: content ?? this.content,
      properties: properties ?? this.properties,
      children: children ?? this.children,
    );
  }
}
