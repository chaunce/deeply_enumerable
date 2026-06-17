# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-06-17

This is a **major, breaking release**. The argument-based `#deep_compact` API has
been replaced with four clearly-named methods, and "blank" now matches Rails'
`#compact_blank` semantics.

### Breaking

- **`#deep_compact` changed meaning.** In v1, bare `deep_compact` defaulted to the
  *most aggressive* behavior. In v2 it removes **only `nil`** (matching Ruby's
  `#compact`). If you relied on the old default, switch to `#deep_compact_blank`.
- **The boolean arguments are gone.** `deep_compact(remove_emptied_elements,
  remove_empty_elements)` is replaced by four dedicated methods (see Added).
- **"Blank" now means `blank?`, not just empty.** The `_blank` family now also
  removes `false` and blank strings (`""`, `" "`), in addition to `nil` and empty
  collections — matching Rails' `#compact_blank`.

### Added

- Four named compaction methods, each with an in-place `!` variant, available as
  instance methods, class methods, and (via `require: "base_extensions"`) directly
  on core `Hash`/`Array`:
  - `#deep_compact` — removes `nil` only.
  - `#deep_compact_existing_blank` — removes `nil` and values that are already
    blank; keeps collections that only become blank through compaction.
  - `#deep_compact_blanked` — removes `nil` and collections emptied by compaction;
    keeps values that were already blank.
  - `#deep_compact_blank` — removes every blank value.
- GitHub Actions CI running RSpec on Ruby 3.3, 3.4, and 4.0.
- A real, comprehensive test suite (43 examples) replacing the previous
  placeholder specs.

### Changed

- Rewrote the internals around a single recursive engine, with doc comments
  linking each method to the Ruby/Rails source it mirrors. Blankness is determined
  by an internal equivalent of ActiveSupport's `Object#blank?`, so the gem still
  has **no ActiveSupport dependency**.
- `base_extensions` now mixes into `Hash`/`Array` the same way ActiveSupport does
  (reopening the class).
- `rake` now runs the RSpec suite (`rake` / `rake spec`); dropped the unused
  Minitest and RDoc tasks.
- Expanded the README with a semantics table, worked examples, and an
  "Upgrading from v1" guide.

### Fixed

- Fixed a latent bug in `#reverse_deep_merge!` (`ebuild` → `rebuild`) that was
  hidden by placeholder specs.

### Upgrading from v1

| v1 call | v2 equivalent |
| --- | --- |
| `deep_compact` / `deep_compact(true, true)` | `deep_compact_blank` |
| `deep_compact(true, false)` | `deep_compact_blanked` |
| `deep_compact(false, true)` | `deep_compact_existing_blank` |
| `deep_compact(false, false)` | `deep_compact` |

## [1.0.0] - 2023-01-18

- Initial release: recursive `#deep_compact` (with `remove_emptied_elements` /
  `remove_empty_elements` flags) and `#reverse_deep_merge` for nested `Hash` and
  `Array` objects.

[2.0.0]: https://github.com/chaunce/deeply_enumerable/compare/1.0.0...2.0.0
[1.0.0]: https://github.com/chaunce/deeply_enumerable/releases/tag/1.0.0
