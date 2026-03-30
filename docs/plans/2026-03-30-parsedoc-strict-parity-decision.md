# Parsedoc Strict Parity Decision

Date: 2026-03-30

## Decision

Searchlight Parsedoc will target strict parity with Orama Parsedoc before any
Searchlight-specific improvements.

That means:

- if the Orama package is a real plugin, the Searchlight package must also be a
  real plugin built on Searchlight's extension/plugin system
- if the Orama package exposes helper APIs such as population or indexing
  helpers, Searchlight Parsedoc must expose equivalent APIs first
- if Orama has capability boundaries or package-shape decisions, Searchlight
  Parsedoc should match them unless there is a documented parity exception
- improvements beyond Orama are allowed only after parity is reached and clearly
  documented as additive behavior

## Current Interpretation

This raises the bar beyond the current companion-parser implementation.

The current package provides:

- Markdown and HTML parsing
- parsed document models
- record mappers for Searchlight
- file helpers for VM use

The audited helper-package parity work is now implemented.

Additive Dart-only parser/model helpers still exist, but they are documented as
additive rather than part of the strict Orama helper contract.

## Audited Orama Package Shape

Audit result from `packages/plugin-parsedoc/src/index.ts`:

- Orama Parsedoc is published as `@orama/plugin-parsedoc`
- the audited source exports helper APIs such as `populate(...)`,
  `populateFromGlob(...)`, `parseFile(...)`, and `defaultHtmlSchema`
- the audited source does **not** export a create-time plugin object or plugin
  factory
- the audited implementation parses documents and calls `insertMultiple(...)`
  directly

That means strict parity for Parsedoc currently requires:

- matching the helper-package public contract first
- not claiming `SearchlightPlugin` integration for Parsedoc unless a later
  source audit shows Orama changed its implementation

This rule still stands for all other packages:

- if an Orama package is a real plugin in source, the Searchlight equivalent
  must also be a real `SearchlightPlugin`

## Implementation Rule

Until parity is reached:

- do not describe Searchlight Parsedoc as "close enough"
- do not collapse "published as a plugin package" and "implemented as a
  create-time plugin" into the same thing; use audited source behavior
- do not add Searchlight-only ergonomic improvements ahead of matching Orama's
  public contract

## Documentation Rule

All planning and spec work for Parsedoc should assume this order:

1. Match Orama exactly where the public implementation is clear.
2. Leave unclear areas reserved rather than guessed.
3. Add improvements only after parity is complete and explicitly documented.
