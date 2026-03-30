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

The current package does not yet prove strict parity because it does not yet
match the full Orama Parsedoc package shape or integration model.

## Implementation Rule

Until parity is reached:

- do not describe Searchlight Parsedoc as "close enough"
- do not treat helper-only parsing parity as sufficient if Orama's package is
  plugin-backed
- do not add Searchlight-only ergonomic improvements ahead of matching Orama's
  public contract

## Documentation Rule

All planning and spec work for Parsedoc should assume this order:

1. Match Orama exactly where the public implementation is clear.
2. Leave unclear areas reserved rather than guessed.
3. Add improvements only after parity is complete and explicitly documented.
