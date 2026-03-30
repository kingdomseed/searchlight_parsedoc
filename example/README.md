# searchlight_parsedoc example

This Flutter example mirrors the base Searchlight example flow, but it routes
Markdown ingestion through `searchlight_parsedoc`.

Dependency split:

- published `searchlight` from pub.dev
- local `searchlight_parsedoc` from `path: ..`

## What it proves

- the app depends on published `searchlight` from pub.dev
- parsing happens through local `searchlight_parsedoc` from a path dependency
- indexing and querying happen through Searchlight
- a user can point the app at a Markdown folder and validate the parsed output
- parsing or duplicate-ID issues collected during loading are surfaced in the UI

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
2. Select a folder containing `.md` files.
3. Wait for indexing to finish.
4. With an empty query, review the alphabetical browse-all list.
5. Search for a term from a heading or body paragraph.
6. Select a result to inspect:
   - parsed title
   - parsed body text
   - source path
   - rendered markdown preview
7. Check the issue count shown above the results list. That count includes
   parse failures and duplicate-ID collisions collected during loading.

## Why this example matters

The example is not using copied Markdown extraction logic. Its folder loader
parses live files with `parseMarkdownFile(...)`, then indexes those mapped
records through published Searchlight.
