# Parsedoc Strict Parity Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Convert `searchlight_parsedoc` from a companion parser package into a strict-parity Dart reimplementation of Orama Parsedoc, including matching the Orama package shape and using Searchlight's plugin system if Orama Parsedoc is a real plugin in source.

**Architecture:** Treat Orama Parsedoc source as the contract. First pin the exact Orama package shape and behavior in a local research/spec pass. Then drive the Dart implementation by tests: public API parity tests, Searchlight integration tests, and plugin wiring tests. Keep current parsing code where it already matches, but move package structure and public APIs to match Orama before adding Searchlight-only improvements.

**Tech Stack:** Dart, Searchlight core plugin system, package:test, Flutter example app, Orama public docs/source audit, TDD.

---

## Task 1: Lock The Orama Parsedoc Contract

**Files:**
- Create: `docs/research/2026-03-30-orama-parsedoc-source-audit.md`
- Modify: `docs/plans/2026-03-30-parsedoc-strict-parity-decision.md`
- Modify: `README.md`

**Step 1: Write the failing parity checklist**

Document a checklist in `docs/research/2026-03-30-orama-parsedoc-source-audit.md` covering:

- exported symbols
- whether the package exposes a real Orama plugin object/factory
- whether `populate(...)` and `populateFromGlob(...)` are the primary public APIs
- whether `defaultHtmlSchema` and any markdown schema exports exist
- input/output document shape
- transform callback payload
- merge strategy behavior
- file/runtime boundaries

**Step 2: Verify the current package fails that checklist**

Run:

```bash
cd /Users/jholt/development/jhd-business/searchlight/.companions/searchlight_parsedoc
dart test
```

Expected:

- current tests pass
- checklist shows missing parity items with no implementation yet

**Step 3: Fill the audit from Orama source, not memory**

Record exact findings from Orama source and docs:

- if Parsedoc is a real plugin in source, note the exported plugin API and when it is used
- if Parsedoc is helper-only despite the package name, record that explicitly
- mark any unclear behavior as reserved instead of guessed

**Step 4: Update the strict-parity decision doc with the audited result**

Add a short section to `docs/plans/2026-03-30-parsedoc-strict-parity-decision.md` stating:

- audited Orama package shape
- whether Searchlight Parsedoc must become a `SearchlightPlugin`
- which public APIs are required for parity

**Step 5: Tighten README status language**

Update `README.md` so it no longer implies current parity if the source audit says parity is still incomplete.

**Step 6: Commit**

```bash
git add docs/research/2026-03-30-orama-parsedoc-source-audit.md docs/plans/2026-03-30-parsedoc-strict-parity-decision.md README.md
git commit -m "docs(parsedoc): lock orama parity contract"
```

## Task 2: Add Public API Parity Tests

**Files:**
- Create: `test/public_api_parity_test.dart`
- Modify: `test/public_api_test.dart`
- Modify: `lib/searchlight_parsedoc.dart`

**Step 1: Write the failing public API test**

Add tests asserting the package exports the audited parity surface, for example:

- `populate(...)`
- `populateFromGlob(...)`
- `defaultHtmlSchema`
- plugin export if Orama source proves one exists

Use `expect(() => symbolReference, returnsNormally)` style smoke tests or direct type assertions.

**Step 2: Run the targeted test to verify it fails**

Run:

```bash
cd /Users/jholt/development/jhd-business/searchlight/.companions/searchlight_parsedoc
dart test test/public_api_parity_test.dart
```

Expected:

- FAIL because the current package only exports parsers and mappers

**Step 3: Add minimal public exports**

Export placeholder parity APIs from `lib/searchlight_parsedoc.dart` with reserved implementations that throw `UnimplementedError` only where the audited contract is still blocked by later tasks.

Do not invent extra Searchlight-only surface here.

**Step 4: Run the targeted test to verify it passes**

Run:

```bash
dart test test/public_api_parity_test.dart
```

Expected:

- PASS on symbol/export presence

**Step 5: Commit**

```bash
git add lib/searchlight_parsedoc.dart test/public_api_parity_test.dart test/public_api_test.dart
git commit -m "test(parsedoc): lock public api parity"
```

## Task 3: Model The Parsedoc Population Contract

**Files:**
- Create: `lib/src/api/populate.dart`
- Create: `lib/src/api/populate_options.dart`
- Create: `test/api/populate_contract_test.dart`
- Modify: `lib/src/searchlight_parsedoc_base.dart`
- Modify: `lib/searchlight_parsedoc.dart`

**Step 1: Write the failing population-contract tests**

Add tests for the audited contract:

- `populate(db, source, options: ...)` accepts parsed content in the audited shape
- `merge`, `split`, and `both` map to the expected insertion behavior
- transform callback receives the audited node payload
- returned value matches the audited Orama behavior

Use fake in-memory Searchlight instances or test seams where needed.

**Step 2: Run the targeted test to verify it fails**

Run:

```bash
cd /Users/jholt/development/jhd-business/searchlight/.companions/searchlight_parsedoc
dart test test/api/populate_contract_test.dart
```

Expected:

- FAIL because no population API exists yet

**Step 3: Add minimal population types**

Implement:

- parity options type
- transform callback type matching the audited payload
- merge strategy mapping required by Orama

Keep this API centered on parity names and shapes, not current internal names if they differ.

**Step 4: Run the targeted test to verify it passes**

Run:

```bash
dart test test/api/populate_contract_test.dart
```

Expected:

- PASS for API shape and pure contract behavior

**Step 5: Commit**

```bash
git add lib/src/api/populate.dart lib/src/api/populate_options.dart lib/src/searchlight_parsedoc_base.dart lib/searchlight_parsedoc.dart test/api/populate_contract_test.dart
git commit -m "feat(parsedoc): add population contract"
```

## Task 4: Implement Searchlight Population Flow

**Files:**
- Create: `lib/src/runtime/searchlight_population.dart`
- Create: `test/runtime/searchlight_population_test.dart`
- Modify: `lib/src/mappers/searchlight_record_mapper.dart`
- Modify: `lib/src/parsers/markdown_parser.dart`
- Modify: `lib/src/parsers/html_parser.dart`
- Modify: `lib/src/models/parsed_document.dart`

**Step 1: Write the failing integration tests**

Add tests proving:

- parsed HTML/Markdown is inserted into a real Searchlight instance
- inserted records use the parity schema/field layout
- `merge`, `split`, and `both` produce the audited document counts
- transform-added properties are preserved exactly as Orama does

Use real Searchlight DB instances in tests.

**Step 2: Run the targeted test to verify it fails**

Run:

```bash
cd /Users/jholt/development/jhd-business/searchlight/.companions/searchlight_parsedoc
dart test test/runtime/searchlight_population_test.dart
```

Expected:

- FAIL because population is not wired to Searchlight yet

**Step 3: Implement minimal runtime behavior**

Implement the real population path:

- parse source
- convert extracted chunks into parity-shaped Searchlight records
- insert records into Searchlight with the correct batch/single behavior

Only change parser/model internals if needed to match the audited Orama output.

**Step 4: Run the targeted test to verify it passes**

Run:

```bash
dart test test/runtime/searchlight_population_test.dart
```

Expected:

- PASS with real Searchlight integration

**Step 5: Commit**

```bash
git add lib/src/runtime/searchlight_population.dart lib/src/mappers/searchlight_record_mapper.dart lib/src/parsers/markdown_parser.dart lib/src/parsers/html_parser.dart lib/src/models/parsed_document.dart test/runtime/searchlight_population_test.dart
git commit -m "feat(parsedoc): populate searchlight indexes"
```

## Task 5: Add Glob And File Population Parity

**Files:**
- Create: `lib/src/io/populate_from_glob.dart`
- Create: `test/io/populate_from_glob_test.dart`
- Modify: `lib/src/io/file_parsers.dart`
- Modify: `lib/searchlight_parsedoc.dart`

**Step 1: Write the failing glob/file tests**

Add tests proving:

- `populateFromGlob(...)` reads matching `.html`, `.htm`, `.md`, and `.markdown` files
- unsupported file types are skipped or rejected exactly as the audited Orama contract says
- file path metadata is preserved exactly where parity requires it

Use temp directories and live fixture files.

**Step 2: Run the targeted test to verify it fails**

Run:

```bash
cd /Users/jholt/development/jhd-business/searchlight/.companions/searchlight_parsedoc
dart test test/io/populate_from_glob_test.dart
```

Expected:

- FAIL because no glob population API exists yet

**Step 3: Implement minimal glob/file behavior**

Implement audited parity behavior only:

- glob expansion
- per-file parser selection
- handoff into `populate(...)`

If Dart needs a package for globbing, add the narrowest dependency that keeps the API honest.

**Step 4: Run the targeted test to verify it passes**

Run:

```bash
dart test test/io/populate_from_glob_test.dart
```

Expected:

- PASS with live-file coverage

**Step 5: Commit**

```bash
git add lib/src/io/populate_from_glob.dart lib/src/io/file_parsers.dart lib/searchlight_parsedoc.dart test/io/populate_from_glob_test.dart
git commit -m "feat(parsedoc): add glob population"
```

## Task 6: Wire Real Plugin Integration If The Audit Requires It

**Files:**
- Create: `lib/src/plugin/parsedoc_plugin.dart`
- Create: `test/plugin/parsedoc_plugin_test.dart`
- Modify: `lib/searchlight_parsedoc.dart`
- Modify: `README.md`

**Step 1: Write the failing plugin integration tests**

Only do this task if Task 1 proves Orama Parsedoc is a real plugin in source.

Add tests proving:

- Searchlight Parsedoc exports a real `SearchlightPlugin`
- the plugin can be passed to `Searchlight.create(plugins: [...])`
- plugin hooks or components are used exactly where Orama source requires them
- helper APIs and plugin APIs cooperate without duplicating behavior

**Step 2: Run the targeted test to verify it fails**

Run:

```bash
cd /Users/jholt/development/jhd-business/searchlight/.companions/searchlight_parsedoc
dart test test/plugin/parsedoc_plugin_test.dart
```

Expected:

- FAIL because no plugin export exists yet

**Step 3: Implement the plugin**

Implement the narrowest real `SearchlightPlugin` needed for parity.

Rules:

- use `SearchlightPlugin` and `SearchlightComponents`, not ad hoc callbacks
- do not wire speculative hooks if Orama source does not use them
- keep helper APIs if Orama exposes both helper and plugin paths

**Step 4: Run the targeted test to verify it passes**

Run:

```bash
dart test test/plugin/parsedoc_plugin_test.dart
```

Expected:

- PASS with real Searchlight plugin wiring

**Step 5: Commit**

```bash
git add lib/src/plugin/parsedoc_plugin.dart lib/searchlight_parsedoc.dart test/plugin/parsedoc_plugin_test.dart README.md
git commit -m "feat(parsedoc): add searchlight plugin"
```

## Task 7: Replace The Example With A True Parity Demo

**Files:**
- Modify: `example/lib/main.dart`
- Modify: `example/lib/src/folder_source_loader_impl_io.dart`
- Modify: `example/lib/src/parsedoc_record_loader.dart`
- Modify: `example/test/widget_test.dart`
- Modify: `example/README.md`

**Step 1: Write the failing example test**

Add a test proving the example uses the parity APIs, not package-internal shortcuts:

- `populate(...)` or `populateFromGlob(...)`
- plugin registration if Task 6 applies

**Step 2: Run the targeted test to verify it fails**

Run:

```bash
cd /Users/jholt/development/jhd-business/searchlight/.companions/searchlight_parsedoc/example
flutter test test/widget_test.dart
```

Expected:

- FAIL because the example currently calls parser helpers directly

**Step 3: Rewire the example**

Use the public parity APIs in the example app so it validates the actual package contract.

Do not keep a separate “example-only” integration path.

**Step 4: Run the targeted test to verify it passes**

Run:

```bash
flutter test test/widget_test.dart
```

Expected:

- PASS with parity APIs exercised end-to-end

**Step 5: Commit**

```bash
git add example/lib/main.dart example/lib/src/folder_source_loader_impl_io.dart example/lib/src/parsedoc_record_loader.dart example/test/widget_test.dart example/README.md
git commit -m "feat(example): validate parsedoc parity flow"
```

## Task 8: Final Verification And Publish-Readiness Docs

**Files:**
- Modify: `README.md`
- Modify: `CHANGELOG.md`
- Modify: `example/README.md`

**Step 1: Write the failing docs checklist**

Create a short checklist in the task notes covering:

- exact parity claims only
- plugin wording only if Task 6 shipped
- platform limitations stated cleanly
- no mention of future improvements as current capability

**Step 2: Run full verification**

Run:

```bash
cd /Users/jholt/development/jhd-business/searchlight/.companions/searchlight_parsedoc
dart analyze
dart test

cd /Users/jholt/development/jhd-business/searchlight/.companions/searchlight_parsedoc/example
flutter analyze
flutter test
```

Expected:

- all checks pass

**Step 3: Finish docs and changelog**

Update docs to reflect the final audited parity result:

- if plugin parity shipped, document plugin usage first
- if helper parity is the audited contract, document helper usage first
- note any still-reserved parity gaps explicitly

**Step 4: Commit**

```bash
git add README.md CHANGELOG.md example/README.md
git commit -m "docs(parsedoc): finalize parity docs"
```
