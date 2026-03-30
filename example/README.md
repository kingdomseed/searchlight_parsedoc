# searchlight_parsedoc example

This Flutter example validates the public Orama-parity helper flow in
`searchlight_parsedoc`.

Dependency split:

- published `searchlight` from pub.dev
- local `searchlight_parsedoc` from `path: ..`

## What it proves

- the app depends on published `searchlight` from pub.dev
- ingestion happens through local `searchlight_parsedoc` from a path dependency
- indexing and querying happen through Searchlight
- a user can point the app at a folder of `.md` and `.html` files
- the app uses `populate(...)` to build the Searchlight database
- the app uses `parseFile(...)` to derive the records shown in the UI
- load issues collected during scanning are surfaced in the UI

## Run

Folder-based validation is a desktop flow. The checked-in app in this repo is
configured for macOS, and the code path also supports Windows and Linux.

From the package root:

```bash
cd example
flutter pub get
flutter run -d macos
```

Run a desktop target. The example below uses macOS because that is the target
configured in this repo.

## Use

1. Click `Choose Folder`.
2. Select a folder containing `.md` or `.html` files.
3. Wait for indexing to finish.
4. With an empty query, review the alphabetical browse-all list.
5. Search for a term from an extracted heading or paragraph record.
6. Select a result to inspect:
   - derived display title
   - extracted content
   - parsed record path
   - source path
   - markdown render or raw source preview
7. Check the issue count shown above the results list. That count covers load
   failures collected during scanning.

## Why this example matters

The example is not using copied extraction logic. Its folder loader reads live
files, uses `populate(...)` to insert Orama-style Parsedoc records into a real
Searchlight database, and uses `parseFile(...)` to derive the displayed record
details from the same public helper surface.
