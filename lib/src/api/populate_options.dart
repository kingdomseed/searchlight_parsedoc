import '../searchlight_parsedoc_base.dart';

typedef PopulateFnContext = Map<String, Object?>;

class NodeContent {
  const NodeContent({
    required this.tag,
    required this.raw,
    required this.content,
    this.properties,
    this.additionalProperties,
  });

  final String tag;
  final String raw;
  final String content;
  final Map<String, Object?>? properties;
  final Map<String, Object?>? additionalProperties;

  NodeContent copyWith({
    String? tag,
    String? raw,
    String? content,
    Map<String, Object?>? properties,
    Map<String, Object?>? additionalProperties,
  }) {
    return NodeContent(
      tag: tag ?? this.tag,
      raw: raw ?? this.raw,
      content: content ?? this.content,
      properties: properties ?? this.properties,
      additionalProperties:
          additionalProperties ?? this.additionalProperties,
    );
  }
}

typedef TransformFn = NodeContent Function(
  NodeContent node,
  PopulateFnContext context,
);

class PopulateOptions {
  const PopulateOptions({
    this.transformFn,
    this.mergeStrategy = MergeStrategy.merge,
    this.context = const <String, Object?>{},
    this.basePath,
  });

  final TransformFn? transformFn;
  final MergeStrategy mergeStrategy;
  final PopulateFnContext context;
  final String? basePath;
}
