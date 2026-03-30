import 'package:searchlight/searchlight.dart';
import 'package:searchlight_parsedoc_example/src/loaded_validation_source.dart';
import 'package:searchlight_parsedoc_example/src/parsedoc_record.dart';
import 'package:searchlight_parsedoc_example/src/search_result_item.dart';
import 'package:searchlight_parsedoc_example/src/validation_issue.dart';

class SearchIndexService {
  const SearchIndexService();

  LoadedValidationSource buildFromRecords({
    required List<ParsedocRecord> records,
    required String label,
    required int discoveredCount,
    List<ValidationIssue> issues = const [],
  }) {
    final db = Searchlight.create(
      schema: Schema({
        'pathLabel': const TypedField(SchemaType.string),
        'title': const TypedField(SchemaType.string),
        'content': const TypedField(SchemaType.string),
        'type': const TypedField(SchemaType.enumType),
        'group': const TypedField(SchemaType.enumType),
        'format': const TypedField(SchemaType.enumType),
        'sourcePath': const TypedField(SchemaType.string),
        'displayBody': const TypedField(SchemaType.string),
      }),
    );

    final recordsById = <String, ParsedocRecord>{};
    for (final record in records) {
      recordsById[record.pathLabel] = record;
      db.insert(record.toSearchDocument());
    }

    return LoadedValidationSource(
      db: db,
      records: List.unmodifiable(records),
      recordsById: Map.unmodifiable(recordsById),
      label: label,
      discoveredCount: discoveredCount,
      issues: List.unmodifiable(issues),
    );
  }

  List<SearchResultItem> browseAll(LoadedValidationSource source) {
    final sorted = [...source.records]
      ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    return sorted
        .map((record) => SearchResultItem(record: record, score: 0))
        .toList(growable: false);
  }

  List<SearchResultItem> search(LoadedValidationSource source, String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return browseAll(source);
    }

    final result = source.db.search(
      term: trimmed,
      properties: const ['title', 'content'],
      limit: source.records.length,
    );

    return result.hits
        .map((hit) {
          final id =
              hit.document.tryGetString('pathLabel') ??
              hit.document.tryGetString('sourcePath') ??
              hit.document.getString('title');
          final record = source.recordsById[id]!;
          return SearchResultItem(record: record, score: hit.score);
        })
        .toList(growable: false);
  }
}
