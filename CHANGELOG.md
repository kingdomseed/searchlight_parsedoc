# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

## [0.2.2] - 2026-03-30

### Changed

- Removed a final round of extraneous companion-package wording from the docs.
- Updated the companion dependency range for `searchlight` `^0.2.2`.

## [0.2.1] - 2026-03-30

### Changed

- Simplified companion-package documentation and removed extraneous wording
  from the package relationship notes.
- Updated the companion dependency range for `searchlight` `^0.2.1`.

## [0.2.0] - 2026-03-30

### Changed

- Updated package docs to explain how `searchlight_parsedoc` combines with
  `searchlight_highlight` for post-search snippets and highlighted matches.
- Updated the companion dependency range for `searchlight` `^0.2.0`.
- Aligned the package family version with `searchlight` and
  `searchlight_highlight`.

## [0.1.0] - 2026-03-30

### Added

- Initial public release of `searchlight_parsedoc` as the HTML and Markdown
  companion package for `searchlight`.
- Parsed document and block models for additive Dart-focused parsing flows.
- Audited Orama-style helper surface:
  - `defaultHtmlSchema`
  - `parseFile(data, fileType, options: ...)`
  - `populate(db, data, fileType, options: ...)`
  - `populateFromGlob(db, pattern, options: ...)`
- Audited transform contract:
  - `NodeContent`
  - `TransformFn`
  - `PopulateFnContext`
- Searchlight-backed runtime population tests and glob tests.

### Changed

- Reworked the example app to use the public parity APIs rather than direct
  internal parser wiring.
- Clarified publish-facing docs and companion-package links for the
  `searchlight` + `searchlight_parsedoc` package pair.
