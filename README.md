# searchlight_parsedoc

`searchlight_parsedoc` is a pure Dart companion package for `searchlight`.

It parses Markdown and HTML into normalized extracted blocks that can then be
mapped into Searchlight records. The package is intentionally narrow:

- supported formats: Markdown and HTML
- string parsing APIs
- live file-path helpers for Dart VM use
- generic record mappers for Searchlight integration
- PDF and broader ingestion stay out of scope for v1

This repo is still in active development, but the core parsing and mapping flow
is already implemented and tested.

## Current status

Implemented:

- `ParsedFormat`
- `ParsedBlock`
- `ParsedDocument`
- `parseMarkdownString(...)`
- `parseHtmlString(...)`
- `parseMarkdownFile(...)`
- `parseHtmlFile(...)`
- `parseFile(...)`
- merge strategies: `merge`, `split`, `both`
- transform callback support
- `SearchlightDocumentRecordMapper`
- `SearchlightBlockRecordMapper`

Planned next:

- README and publish-readiness polish

## Scope

`searchlight_parsedoc` is not a generic ingestion framework.

V1 intentionally does not include:

- PDF parsing
- recursive folder walking
- glob APIs
- front matter extraction
- remote download helpers
- Searchlight database creation
- automatic insertion into a Searchlight index

The package stops at parsed document models and plain record maps.

## Usage

```dart
import 'package:searchlight_parsedoc/searchlight_parsedoc.dart';

Future<void> main() async {
  final doc = await parseMarkdownString('''
# Ember Lance

A focused lance of heat.
''');

  print(doc.title);
  print(doc.bodyText);
}
```

Map a parsed document into a Searchlight-ready record:

```dart
import 'package:searchlight_parsedoc/searchlight_parsedoc.dart';

Future<void> main() async {
  final doc = await parseMarkdownFile('docs/ember.md');

  final record = const SearchlightDocumentRecordMapper().map(
    id: 'ember-lance',
    document: doc,
  );

  print(record);
}
```

## Additional information

This package follows Searchlight's architecture split:

- `searchlight` core owns indexing and search
- companion packages own source-format extraction

Web callers should load text through app code first, then call the string-based
parsers. File-path helpers use `dart:io` and are intended for VM environments.
