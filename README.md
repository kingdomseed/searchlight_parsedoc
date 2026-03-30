# searchlight_parsedoc

`searchlight_parsedoc` is a pure Dart companion package for `searchlight`.

It parses Markdown and HTML into normalized extracted blocks that can then be
mapped into Searchlight records. The package is intentionally narrow:

- supported formats: Markdown and HTML
- string parsing APIs first
- file-path helpers later
- PDF and broader ingestion stay out of scope for v1

This repo is in active development. The initial public surface and the first
Markdown/HTML parsing slices are in place, but the package is not yet ready for
pub.dev.

## Current status

Implemented:

- `ParsedFormat`
- `ParsedBlock`
- `ParsedDocument`
- `parseMarkdownString(...)`
- `parseHtmlString(...)`

Planned next:

- merge strategies
- transform callback support
- Searchlight record mappers
- live file helpers
- README and publish-readiness polish

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

## Additional information

This package follows Searchlight's architecture split:

- `searchlight` core owns indexing and search
- companion packages own source-format extraction

For now, development happens locally before the package is moved into its final
standalone location.
