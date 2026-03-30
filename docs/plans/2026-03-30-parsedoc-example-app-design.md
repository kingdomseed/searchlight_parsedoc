# Parsedoc Example App Design

## Goal

Add a Flutter desktop example app to `searchlight_parsedoc` that mirrors the
base `searchlight` example app closely enough to compare behavior, while
proving that `searchlight_parsedoc` plugs into the published `searchlight`
package in a real indexing flow.

## Required Constraints

- The example app lives in `searchlight_parsedoc/example`.
- The example app depends explicitly on published `searchlight` from pub.dev.
- The example app also depends on the local package under development:
  `searchlight_parsedoc`.
- The example app recreates the same broad UX flow as the base Searchlight
  example:
  - desktop folder picker
  - load/index state
  - query field
  - result list
  - selected-document preview
- The ingestion path must go through `searchlight_parsedoc`, not a local
  duplicate Markdown extractor.

## Non-Goals

- Do not build a generalized shared example framework across repos.
- Do not add web/mobile import flows now.
- Do not add HTML folder ingestion in the first pass.
- Do not turn the example app into a publishable package.
- Do not create a dependency from `searchlight` back to `searchlight_parsedoc`.

## Recommended Approach

Recreate the base Searchlight example app structure inside this repo and swap
only the extraction layer.

That means:

- copy the base example's architecture and UX patterns
- keep the same folder-driven validation workflow
- replace custom Markdown record extraction with:
  - `parseMarkdownFile(...)`
  - `SearchlightDocumentRecordMapper`
  - indexing through published `searchlight`

This gives us the cleanest proof that parsedoc is working as an add-on rather
than as baked-in core behavior.

## App Architecture

### Dependencies

The Flutter example app should depend on:

- `flutter`
- `file_selector`
- `flutter_markdown_plus`
- `path`
- published `searchlight`
- local path dependency on `searchlight_parsedoc`

### Data Flow

1. User chooses a folder.
2. The app scans Markdown files in that folder.
3. For each Markdown file:
   - read original source for preview
   - parse through `searchlight_parsedoc`
   - map the parsed document into a Searchlight record
4. Build a Searchlight index from those mapped records.
5. Run searches against the Searchlight database.
6. Show:
   - search results
   - parsed title/body fields
   - original source preview
   - optional parsed-block diagnostics if useful

### Record Shape

The example app should use a simple explicit record shape so the Searchlight
integration is obvious:

```dart
{
  'id': 'docs/spells/ember-lance.md',
  'title': 'Ember Lance',
  'content': 'A focused lance of heat.',
  'sourcePath': '.../ember-lance.md',
  'format': 'markdown',
}
```

This keeps the app aligned with Searchlight's common usage and keeps the parsed
output legible in the UI.

## UX Shape

The UI should stay close to the base Searchlight example:

- header with app title and purpose
- folder-selection action
- current source label
- query field
- result count / issue count
- split view:
  - result list on one side
  - selected document preview on the other

The preview panel should show:

- parsed title
- searchable body text
- source path
- original markdown source rendered with `flutter_markdown_plus`

That combination makes it easy to judge whether parsedoc extracted the right
searchable content.

## Validation Contract

The example app must prove three things:

1. the app depends on published `searchlight`
2. indexing happens through Searchlight, not ad hoc string matching
3. extraction happens through `searchlight_parsedoc`, not copied extraction code

## Testing Strategy

### Widget tests

Add tests that cover:

- loading a fake folder result
- building the index from parsedoc-derived records
- searching and showing the expected hit
- selecting a result and showing parsed/original preview data

### Focused unit tests

Add a test around the example's parsedoc adapter layer proving that a Markdown
file path is parsed with `parseMarkdownFile(...)` and mapped into the example
record shape.

## Why This Design

This is the simplest honest proof of parsedoc extraction behavior:

- Searchlight stays the engine
- parsedoc stays the extraction layer
- the example shows the integration boundary clearly

That is exactly what we want before publishing the package more broadly.

This document predates the later strict-parity decision and should not be read
as proof that the package already matches Orama's plugin shape.
