# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

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
