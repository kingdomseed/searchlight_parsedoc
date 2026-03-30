# Parsedoc Example App Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a Flutter desktop example app to `searchlight_parsedoc` that mirrors the base Searchlight example flow and proves parsedoc integrates with the published `searchlight` package.

**Architecture:** Recreate the base Searchlight example's folder-driven validation app inside `searchlight_parsedoc/example`, but replace the base example's Markdown extraction layer with `parseMarkdownFile(...)` plus parsedoc record mapping. Keep Searchlight as the indexing/query engine and keep parsedoc as the extraction boundary.

**Tech Stack:** Flutter, published `searchlight`, local `searchlight_parsedoc`, `file_selector`, `flutter_markdown_plus`, `path`, widget tests.

---

## Global Rules

- The example app must depend on published `searchlight`, not a local path.
- The example app must depend on local `searchlight_parsedoc` by path.
- Keep the base example's UX shape recognizable.
- Do not add web/mobile source flows in this first pass.
- Keep folder ingestion Markdown-first.
- Keep TDD honest for every new behavior slice.

## Task 1: Bootstrap The Flutter Example App

**Files:**
- Modify: `example/pubspec.yaml`
- Create: `example/lib/main.dart`
- Create: `example/test/widget_test.dart`

**Step 1: Write the failing test**

Add a widget test that expects the example app to render:

- an app title mentioning parsedoc
- a folder-selection action
- a search field

**Step 2: Run test to verify it fails**

Run:

```bash
cd /Users/jholt/development/jhd-business/searchlight/.companions/searchlight_parsedoc/example
flutter test test/widget_test.dart
```

Expected:
- FAIL because no Flutter example app exists yet

**Step 3: Write minimal implementation**

- convert `example/` from Dart console example to Flutter app
- add published `searchlight` dependency
- add local path dependency on `searchlight_parsedoc`
- render the initial shell UI

**Step 4: Run test to verify it passes**

Run:

```bash
cd /Users/jholt/development/jhd-business/searchlight/.companions/searchlight_parsedoc/example
flutter test test/widget_test.dart
flutter analyze
```

Expected:
- PASS
- analyzer clean

**Step 5: Commit**

```bash
git add -A
git commit -m "feat(example): bootstrap parsedoc validation app"
```

## Task 2: Add Folder Loading And Parsedoc Adapter

**Files:**
- Create: `example/lib/src/folder_source_loader.dart`
- Create: `example/lib/src/folder_source_loader_impl_io.dart`
- Create: `example/lib/src/folder_source_loader_impl_stub.dart`
- Create: `example/lib/src/parsedoc_record.dart`
- Create: `example/lib/src/parsedoc_record_loader.dart`
- Test: `example/test/parsedoc_record_loader_test.dart`

**Step 1: Write the failing test**

Write a test proving a live Markdown file path is:

- parsed through `parseMarkdownFile(...)`
- converted into the example record shape

**Step 2: Run test to verify it fails**

Run:

```bash
cd /Users/jholt/development/jhd-business/searchlight/.companions/searchlight_parsedoc/example
flutter test test/parsedoc_record_loader_test.dart
```

Expected:
- FAIL because no parsedoc adapter exists yet

**Step 3: Write minimal implementation**

- add folder loading abstraction
- add parsedoc-based record loader
- keep only `.md` file discovery in the first pass

**Step 4: Run test to verify it passes**

Run:

```bash
cd /Users/jholt/development/jhd-business/searchlight/.companions/searchlight_parsedoc/example
flutter test test/parsedoc_record_loader_test.dart
flutter analyze
```

Expected:
- PASS
- analyzer clean

**Step 5: Commit**

```bash
git add -A
git commit -m "feat(example): load markdown folders through parsedoc"
```

## Task 3: Index Parsedoc Records With Published Searchlight

**Files:**
- Create: `example/lib/src/search_index_service.dart`
- Create: `example/lib/src/search_result_item.dart`
- Modify: `example/lib/main.dart`
- Test: `example/test/widget_test.dart`

**Step 1: Write the failing test**

Extend the widget test so it loads fake parsedoc records, enters a query, and
expects a matching result.

**Step 2: Run test to verify it fails**

Run:

```bash
cd /Users/jholt/development/jhd-business/searchlight/.companions/searchlight_parsedoc/example
flutter test test/widget_test.dart
```

Expected:
- FAIL because Searchlight-backed search is not wired yet

**Step 3: Write minimal implementation**

- build Searchlight records from parsedoc output
- create a Searchlight database in the example app
- wire search results into the UI

**Step 4: Run test to verify it passes**

Run:

```bash
cd /Users/jholt/development/jhd-business/searchlight/.companions/searchlight_parsedoc/example
flutter test test/widget_test.dart
flutter analyze
```

Expected:
- PASS
- analyzer clean

**Step 5: Commit**

```bash
git add -A
git commit -m "feat(example): index parsedoc records with searchlight"
```

## Task 4: Add Result Detail Preview

**Files:**
- Modify: `example/lib/main.dart`
- Create: `example/lib/src/search_result_item.dart`
- Test: `example/test/widget_test.dart`

**Step 1: Write the failing test**

Extend the widget test so selecting a result shows:

- parsed title
- parsed body text
- rendered original markdown preview

**Step 2: Run test to verify it fails**

Run:

```bash
cd /Users/jholt/development/jhd-business/searchlight/.companions/searchlight_parsedoc/example
flutter test test/widget_test.dart
```

Expected:
- FAIL because detail preview is incomplete

**Step 3: Write minimal implementation**

- add selected-result state
- add split layout like the base example
- render original markdown through `flutter_markdown_plus`

**Step 4: Run test to verify it passes**

Run:

```bash
cd /Users/jholt/development/jhd-business/searchlight/.companions/searchlight_parsedoc/example
flutter test test/widget_test.dart
flutter analyze
```

Expected:
- PASS
- analyzer clean

**Step 5: Commit**

```bash
git add -A
git commit -m "feat(example): add parsed document preview"
```

## Task 5: Document And Verify The Example App

**Files:**
- Modify: `README.md`
- Modify: `example/README.md`
- Test: `example/test/widget_test.dart`

**Step 1: Write or extend the failing regression test if README examples need API proof**

Keep at most one small compile-valid usage proof if the docs depend on it.

**Step 2: Write the docs**

Document:

- that the example depends on published `searchlight`
- that folder indexing runs through `searchlight_parsedoc`
- how to run the app
- how to point it at a Markdown folder
- how to manually validate that parsed content is what gets indexed

**Step 3: Run full verification**

Run:

```bash
cd /Users/jholt/development/jhd-business/searchlight/.companions/searchlight_parsedoc
dart analyze
dart test
cd example
flutter pub get
flutter analyze
flutter test
```

Expected:
- root package analyze/test passes
- example analyze/test passes

**Step 4: Commit**

```bash
git add -A
git commit -m "docs(example): document parsedoc validation app"
```
