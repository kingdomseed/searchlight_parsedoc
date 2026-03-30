import 'models/parsed_node.dart';
import 'models/merge_strategy.dart';

export 'models/parsed_document.dart';
export 'models/merge_strategy.dart';
export 'models/parsed_node.dart';
export 'api/populate.dart';
export 'api/populate_options.dart';
export 'io/file_parsers.dart';
export 'io/populate_from_glob.dart';
export 'mappers/searchlight_record_mapper.dart';
export 'parsers/html_parser.dart';
export 'parsers/markdown_parser.dart';

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
