# Searchlight Parsedoc

[![Pub Version](https://img.shields.io/pub/v/searchlight_parsedoc)](https://pub.dev/packages/searchlight_parsedoc)
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/kingdomseed/searchlight_parsedoc)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Repository](https://img.shields.io/badge/repository-kingdomseed%2Fsearchlight__parsedoc-24292f)](https://github.com/kingdomseed/searchlight_parsedoc)
[![Publisher](https://img.shields.io/badge/publisher-jasonholtdigital.com-2b7cff)](https://pub.dev/publishers/jasonholtdigital.com)

Searchlight Parsedoc is a pure Dart reimplementation of Orama's Parsedoc
helper package shape for Searchlight, the independent Dart reimplementation of
Orama's in-memory search and indexing model.

Package links:

- `searchlight` on pub.dev: <https://pub.dev/packages/searchlight>
- `searchlight` on GitHub: <https://github.com/kingdomseed/searchlight>
- `searchlight_parsedoc` on pub.dev:
  <https://pub.dev/packages/searchlight_parsedoc>
- `searchlight_parsedoc` on GitHub:
  <https://github.com/kingdomseed/searchlight_parsedoc>

It turns HTML and Markdown into flat Searchlight-ready records through the same
core helper surface Orama exposes:

- `defaultHtmlSchema`
- `parseFile(...)`
- `populate(...)`
- `populateFromGlob(...)`

## Status

`searchlight_parsedoc` matches the audited Orama Parsedoc helper contract:

- `defaultHtmlSchema`
- `parseFile(data, fileType, options: ...)`
- `populate(db, data, fileType, options: ...)`
- `populateFromGlob(db, pattern, options: ...)`
- `MergeStrategy`
- `NodeContent`
- `TransformFn`
- `PopulateFnContext`

Important package-shape note:

- Orama publishes Parsedoc as `@orama/plugin-parsedoc`
- the audited Orama source is helper-driven, not a create-time plugin object
- Searchlight Parsedoc matches that audited helper shape

## Platform Support

`searchlight_parsedoc` is a pure Dart package, but the current top-level import
also exports `dart:io` helpers such as `populateFromGlob(...)`,
`parseMarkdownFile(...)`, `parseHtmlFile(...)`, and `parseLocalFile(...)`.

That means:

- import `package:searchlight_parsedoc/searchlight_parsedoc.dart` only in Dart
  or Flutter VM targets for now
- `parseFile(...)` and `populate(...)` accept `String` or `List<int>` input
- separate web-safe exports are not available yet

## Installation

```bash
dart pub add searchlight_parsedoc

# or from a Flutter app
flutter pub add searchlight_parsedoc
```

## Quick Start

Create a Searchlight database that covers the minimal searchable Parsedoc
fields:

```dart
import 'package:searchlight/searchlight.dart';
import 'package:searchlight_parsedoc/searchlight_parsedoc.dart';

final db = Searchlight.create(
  schema: Schema({
    'type': const TypedField(SchemaType.string),
    'content': const TypedField(SchemaType.string),
    'path': const TypedField(SchemaType.string),
  }),
);
```

Populate it from Markdown or HTML content:

```dart
import 'dart:convert';

import 'package:searchlight/searchlight.dart';
import 'package:searchlight_parsedoc/searchlight_parsedoc.dart';

Future<void> main() async {
  final db = Searchlight.create(
    schema: Schema({
      'type': const TypedField(SchemaType.string),
      'content': const TypedField(SchemaType.string),
      'path': const TypedField(SchemaType.string),
    }),
  );

  final ids = await populate(
    db,
    utf8.encode('# Ember Lance\n\nA focused lance of heat.'),
    'md',
  );

  final result = db.search(
    term: 'ember',
    properties: const ['content'],
  );

  print(ids);
  print(result.count);

  await db.dispose();
}
```

Inspect extracted records without inserting them:

```dart
import 'dart:convert';

import 'package:searchlight_parsedoc/searchlight_parsedoc.dart';

Future<void> main() async {
  final records = await parseFile(
    utf8.encode('<div><p>First</p><p>Second</p></div>'),
    'html',
  );

  print(records);
}
```

The extracted record shape matches the audited Orama helper contract:

```dart
{
  'type': 'p',
  'content': 'First Second',
  'path': 'root[0].div[0]',
  'properties': <String, Object?>{},
}
```

`properties` is optional record metadata. It is not part of
`defaultHtmlSchema`, and Searchlight does not need it declared in the schema
unless you choose to model it yourself outside the default helper path.

## Merge Strategies

Parsedoc exposes the same merge modes as Orama:

- `MergeStrategy.merge`: merge consecutive compatible sibling text nodes
- `MergeStrategy.split`: emit one record per text node
- `MergeStrategy.both`: emit split records plus a merged companion record

## Transform Contract

The transform contract matches the audited Orama helper payload:

```dart
final options = PopulateOptions(
  transformFn: (node, context) {
    return node.copyWith(
      additionalProperties: {'section': context['section']},
    );
  },
  context: const {'section': 'intro'},
);
```

`NodeContent` exposes:

- `tag`
- `raw`
- `content`
- `properties`
- `additionalProperties`

## Folder Population

For VM targets, `populateFromGlob(...)` mirrors Orama's folder-ingestion
helper:

```dart
import 'package:searchlight/searchlight.dart';
import 'package:searchlight_parsedoc/searchlight_parsedoc.dart';

Future<void> main() async {
  final db = Searchlight.create(
    schema: Schema({
      'type': const TypedField(SchemaType.string),
      'content': const TypedField(SchemaType.string),
      'path': const TypedField(SchemaType.string),
    }),
  );

  await populateFromGlob(db, 'content/*');
  await db.dispose();
}
```

Audited parity note:

- the current helper supports `.md` and `.html`
- `.markdown` and `.htm` are not part of the audited Orama helper contract

## Additive Dart APIs

Beyond the audited Orama helper surface, this package also keeps additive
Dart-oriented parser/model APIs:

- `ParsedFormat`
- `ParsedBlock`
- `ParsedDocument`
- `parseMarkdownString(...)`
- `parseHtmlString(...)`
- `parseMarkdownFile(...)`
- `parseHtmlFile(...)`
- `parseLocalFile(...)`
- `SearchlightDocumentRecordMapper`
- `SearchlightBlockRecordMapper`

These APIs are additive. They are useful for Dart apps, but they are not part
of the strict Orama Parsedoc helper contract.

## Example App

The repo includes a Flutter desktop validation app under
[`example/`](example/README.md).

That app is intentionally wired through the public parity surface:

- it depends on published [`searchlight`](https://pub.dev/packages/searchlight)
  from pub.dev
- it depends on local `searchlight_parsedoc` by path
- it loads a folder of live `.md` and `.html` files
- it uses `populate(...)` plus `parseFile(...)`
- it searches the populated Searchlight database
- it lets you inspect extracted record paths alongside the source preview

## Additional Information

This package follows Searchlight's architecture split:

- `searchlight` core owns indexing and search
- companion packages own source-format extraction and ingestion helpers
