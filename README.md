# Searchlight Parsedoc

[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/kingdomseed/searchlight_parsedoc)
[![Repository](https://img.shields.io/badge/repository-kingdomseed%2Fsearchlight__parsedoc-24292f)](https://github.com/kingdomseed/searchlight_parsedoc)

Searchlight Parsedoc is a pure Dart companion package for Searchlight, the
independent Dart reimplementation of Orama's in-memory search and indexing
model. It parses Markdown and HTML into extracted documents and record maps for
Dart and Flutter apps.

Searchlight Parsedoc is especially useful when your app already has Markdown or
HTML available as strings or local files, and you want a reusable conversion
step before indexing that content with Searchlight.

## Status

`searchlight_parsedoc` is currently a parser-first companion package for
Searchlight. It is not yet at strict Orama Parsedoc parity.

Today it includes parsing and mapping primitives:

Current API includes:

- `ParsedFormat`
- `ParsedBlock`
- `ParsedDocument`
- `parseMarkdownString(...)`
- `parseHtmlString(...)`
- `parseMarkdownFile(...)`
- `parseHtmlFile(...)`
- `parseFile(...)`
- merge strategies: `merge`, `split`, `both`
- transform callback support through `ParseOptions`
- `SearchlightDocumentRecordMapper`
- `SearchlightBlockRecordMapper`

It does not currently include:

- Orama-style `populate(...)`
- Orama-style `populateFromGlob(...)`
- `defaultHtmlSchema`
- PDF parsing
- recursive folder walking
- glob APIs
- front matter extraction
- remote download helpers
- Searchlight database creation
- automatic insertion into a Searchlight index

## Scope

`searchlight_parsedoc` is intentionally focused. It stops at parsed document
models and opinionated record maps today. The next parity phase will add the
Orama-style population APIs before any Searchlight-specific improvements.

## Platform Support

`searchlight_parsedoc` is a pure Dart package. String parsing is platform
agnostic, but the current top-level library also exports `dart:io` file
helpers. Import `package:searchlight_parsedoc/searchlight_parsedoc.dart` in
Dart or Flutter VM targets for now. Separate web-safe exports are not
available yet.

## Start Here

- Use the string parsers when your app has already loaded Markdown or HTML
  content.
- Use the file parsers in Dart VM code when you want to read local `.md`,
  `.markdown`, `.html`, or `.htm` files directly.
- Open [example/README.md](example/README.md) for the Flutter desktop
  validation app.

## Installation

```bash
dart pub add searchlight_parsedoc

# or from a Flutter app
flutter pub add searchlight_parsedoc
```

## Quick Start

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

Map a parsed document into a Searchlight-ready record using the default
document-level field layout:

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

The default document mapper emits this shape:

```dart
{
  'id': 'ember-lance',
  'title': 'Ember Lance',
  'content': 'A focused lance of heat.',
  'sourcePath': 'docs/ember.md',
  'format': 'markdown',
}
```

The default block mapper emits one record per extracted block:

```dart
{
  'id': 'ember-lance#0',
  'documentId': 'ember-lance',
  'sourcePath': 'docs/ember.md',
  'format': 'markdown',
  'tag': 'p',
  'content': 'A focused lance of heat.',
  'path': 'root.body[0]',
  'attributes': <String, String>{},
}
```

These are opinionated `Map<String, Object?>` helpers. They do not create a
Searchlight database for you, and your Searchlight schema must declare the
fields you plan to index from those maps.

For the default document mapper, that usually means a schema along these lines:

```dart
final schema = {
  'id': 'string',
  'title': 'string',
  'content': 'string',
  'sourcePath': 'string',
  'format': 'string',
};
```

## Example app

The repo includes a Flutter desktop example app under
[`example/`](example/README.md).

That app is intentionally a real integration proof:

- it depends on published `searchlight` from pub.dev
- it depends on local `searchlight_parsedoc` by path
- it loads a folder of Markdown files
- it parses those files through `searchlight_parsedoc`
- it indexes the resulting records with Searchlight
- it lets you search and inspect the parsed output next to a rendered markdown
  preview
- the current checked-in app targets macOS in this repo

## Additional information

This package follows Searchlight's architecture split:

- `searchlight` core owns indexing and search
- companion packages own source-format extraction
