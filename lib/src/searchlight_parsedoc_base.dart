import 'models/parsed_node.dart';

export 'models/parsed_document.dart';
export 'models/parsed_node.dart';
export 'api/populate.dart';
export 'io/file_parsers.dart';
export 'mappers/searchlight_record_mapper.dart';
export 'parsers/html_parser.dart';
export 'parsers/markdown_parser.dart';

enum MergeStrategy {
  merge,
  split,
  both,
}

typedef ParsedocTransform = ParsedNode Function(
  ParsedNode node,
  ParsedocTransformContext context,
);

class ParseOptions {
  const ParseOptions({
    this.mergeStrategy = MergeStrategy.merge,
    this.transform,
    this.context = const <String, Object?>{},
  });

  final MergeStrategy mergeStrategy;
  final ParsedocTransform? transform;
  final ParsedocTransformContext context;
}
