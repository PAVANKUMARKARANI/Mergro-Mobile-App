# Mergro agent instructions

## Before significant work

1. Read this file, [skill.md](skill.md), and [standards.md](standards.md).
2. Inspect the actual source files and relevant tests before changing anything. Treat `skill.md` as implementation history, not as a substitute for checking current code; reconcile any discrepancy against the source.
3. Inspect `git status` and the current diff when Git is available. Preserve all unrelated user changes; never discard, revert, or overwrite them.

## Implementation rules

- Follow `standards.md` and preserve the existing Flutter feature architecture, Riverpod 3 conventions, design tokens, shared widgets, imperative routing in `lib/app/app_routes.dart`, and testing patterns. Do not copy the standards into this file.
- Keep every Dart file at or below Mergro's 250-line hard limit, splitting by responsibility when needed.
- Respect every `// TODO(backend):` marker. Do not present simulated or demo behavior as a real backend integration, and do not invent API contracts.
- Do not change dependencies without the approval required by `standards.md`.

## Documentation after implementation

Update `skill.md` in the same change:

- Update the progress checklist and add a newest-first implementation-log entry.
- Update the Providers or `TODO(backend)` tables when relevant, and update Files created when files are added.
- Record only commands and checks actually run. Separate verified results from behavior that remains unverified.
- If work stops midway, record completed work, partial progress, files changed, checks run, remaining work, and the exact next recommended task.

## Switching between agents

Before switching, inspect Git status and the current diff, then update `skill.md` with completed work, partial progress, files modified, checks run, and remaining work. On starting, read the project documents, inspect the actual code, and reconcile the log with source and the current diff. Never assume another agent's chat history is available. Do not let two agents modify the same working tree at the same time; finish or pause one agent before the other starts editing.
