# searchlight_parsedoc example

This Flutter desktop example mirrors the base Searchlight example flow, but it
routes Markdown ingestion through `searchlight_parsedoc`.

## What it proves

- the app depends on published `searchlight`
- parsing happens through `searchlight_parsedoc`
- indexing and querying happen through Searchlight
- a user can point the app at a Markdown folder and validate the parsed output

## Run

From the package root:

```bash
cd example
flutter pub get
flutter run -d macos
```

## Use

1. Click `Choose Folder`.
2. Select a folder containing `.md` files.
3. Wait for indexing to finish.
4. Search for a term from a heading or body paragraph.
5. Select a result to inspect:
   - parsed title
   - parsed body text
   - source path
   - rendered markdown preview

## Why this example matters

The example is not using copied Markdown extraction logic. Its folder loader
parses live files with `parseMarkdownFile(...)`, then indexes those mapped
records through Searchlight.
