# Worklog

## 2026-05-08
- Removed stale preference assets, an unreferenced snippet xib, and one-use Array/String helpers.
- Added `AppPreferences` for typed defaults/observers and moved clip pasteboard writing into `CPYClipData`.
- Extracted snippet XML import/export into `SnippetXMLService`.
- Fixed unmanaged `CPYFolder.deepCopy()` so snippets are preserved.
- Verified the full test suite with `xcodebuild test`.
