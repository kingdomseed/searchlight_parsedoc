# Orama Parsedoc Source Audit

Date: 2026-03-30

Primary source:

- `packages/plugin-parsedoc/src/index.ts` from the Orama monorepo
- `packages/plugin-parsedoc/package.json`
- `packages/plugin-parsedoc/README.md`

## Audited Package Shape

Orama ships Parsedoc as the package `@orama/plugin-parsedoc`, but the audited
source file exports helper APIs rather than a create-time Orama plugin object.

Audited exports from `src/index.ts`:

- `defaultHtmlSchema`
- `populateFromGlob(...)`
- `parseFile(...)`
- `populate(...)`
- `NodeContent`
- `TransformFn`
- `MergeStrategy`
- `DefaultSchemaElement`
- `PopulateFnContext`

## Plugin-System Finding

The audited `src/index.ts` does **not** export a plugin registration object,
plugin factory, `getComponents(...)`, or hook bundle.

Instead:

- `populate(...)` parses input and then calls `insertMultiple(db, ...)`
- `populateFromGlob(...)` expands files and delegates to `populateFromFile(...)`
- `populateFromFile(...)` is internal, not exported

Strict parity for Parsedoc therefore means matching this helper-package shape
first. It does **not** currently require `Searchlight.create(plugins: [...])`
integration for Parsedoc itself.

This does **not** weaken the broader plugin rule:

- if an Orama package is a real plugin in source, the Searchlight equivalent
  must be a real `SearchlightPlugin`
- Parsedoc is the audited exception because the Orama source does not expose it
  that way

## Public Contract Findings

### `defaultHtmlSchema`

Audited shape:

```ts
{
  type: 'string',
  content: 'string',
  path: 'string'
}
```

Notes:

- this is a record schema, not a parsed document model
- `properties` is present on inserted records but not in `defaultHtmlSchema`

### `DefaultSchemaElement`

Audited shape:

- `type: string`
- `content: string`
- `path: string`
- `properties?: Properties`

Notes:

- Orama Parsedoc emits flat record elements, not a retained parsed-document
  model as its primary public output

### `MergeStrategy`

Audited string union:

- `merge`
- `split`
- `both`

Behavior:

- `merge`: merge consecutive compatible records into the last record
- `split`: emit one record per visited text node
- `both`: emit a split record and maintain a merged companion record

### `TransformFn`

Audited transform payload:

```ts
type TransformFn = (node: NodeContent, context: PopulateFnContext) => NodeContent
```

Audited `NodeContent` shape:

- `tag`
- `raw`
- `content`
- `properties?`
- `additionalProperties?`

Notes:

- this differs from the current Searchlight Parsedoc transform shape
- the current Dart package exposes `ParsedNode` with `text`, `rawMarkup`, and
  `attributes`, which is not strict parity

### `populate(...)`

Audited signature:

- accepts a database instance
- accepts `Buffer | string`
- accepts explicit `fileType` (`'html' | 'md'`)
- accepts options including `transformFn`, `mergeStrategy`, `context`,
  `basePath`

Behavior:

- calls `parseFile(...)`
- inserts the returned records with `insertMultiple(...)`
- returns the inserted document IDs from Orama

### `populateFromGlob(...)`

Audited behavior:

- accepts a glob pattern
- resolves files with `glob`
- reads each file
- infers file type from extension
- delegates into the same populate path

Supported audited extensions in practice:

- `.md`
- `.html`

The helper uses a `FileType` union of `'html' | 'md'`. There is no audited
support for `.markdown` or `.htm` in `populateFromFile(...)`.

## Parity Status Against Current Dart Package

The original gaps identified in this audit were:

- no `populate(...)`
- no `populateFromGlob(...)`
- no `defaultHtmlSchema`
- no parity `TransformFn` / `NodeContent` surface
- current package centered parsed-document models rather than Orama-style flat
  record elements
- current README described the package primarily as a parser/mapping layer

Those audited helper-surface gaps are now implemented in Searchlight Parsedoc.

The remaining non-parity questions are additive-package questions, not missing
core helper contract pieces.

## Reserved Questions

These should stay reserved until implemented or re-audited:

- whether Searchlight Parsedoc should retain parsed-document helpers as additive
  APIs after parity is complete
- whether we expose `.markdown` / `.htm` support as additive behavior later
- whether Searchlight should mirror Orama's exact return type semantics for
  inserted IDs or map them through Searchlight-native types
