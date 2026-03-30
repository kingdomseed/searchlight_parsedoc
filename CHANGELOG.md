## 0.1.0-dev

- Bootstrap standalone package repo.
- Add parsed document model.
- Add initial Markdown and HTML string parsing.
- Add audited Orama-style helper surface:
  - `defaultHtmlSchema`
  - `parseFile(data, fileType, options: ...)`
  - `populate(db, data, fileType, options: ...)`
  - `populateFromGlob(db, pattern, options: ...)`
- Add audited transform contract:
  - `NodeContent`
  - `TransformFn`
  - `PopulateFnContext`
- Add Searchlight-backed runtime population tests and glob tests.
- Rework the example app to use the public parity APIs rather than direct
  internal parser wiring.
