# DeeplyEnumerable
Extend `Enumerable` objects with recursive versions of common operations.

`DeeplyEnumerable` walks a nested structure of `Hash` and `Array` objects and
applies an operation at every level. Nested `Enumerable` objects are converted
into `DeeplyEnumerable` types during the operation so the recursion can continue
all the way down.

## Compaction
Ruby's `#compact` removes `nil`. Rails' `#compact_blank` removes anything that is
`blank?` (`nil`, `false`, `""`, `" "`, `[]`, `{}`). `DeeplyEnumerable` provides
recursive versions of both, plus two methods in between for finer control over
*which* blanks are removed:

| Method | Removes | Keeps |
| --- | --- | --- |
| `#deep_compact` | `nil` only | every other value, including `""`, `false`, `[]`, `{}` |
| `#deep_compact_existing_blank` | `nil` and values that are **already** blank | collections that only become blank through compaction |
| `#deep_compact_blanked` | `nil` and collections **emptied** by compaction | values that were already blank |
| `#deep_compact_blank` | every blank value | nothing blank |

The distinction between "existing" and "emptied" blanks matters once nesting is
involved. Consider `{ a: { b: nil }, c: [] }`:

* `a` holds `{ b: nil }`, which is *not* blank until its `nil` is removed — an
  **emptied** blank.
* `c` holds `[]`, which is blank in the input — an **existing** blank.

```ruby
source = { a: :b, c: nil, d: { e: nil, f: [] }, g: [1, nil], h: {}, i: "", j: [nil] }

DeeplyEnumerable::Hash.deep_compact(source)
# => { a: :b, d: { f: [] }, g: [1], h: {}, i: "", j: [] }   # only nils removed

DeeplyEnumerable::Hash.deep_compact_existing_blank(source)
# => { a: :b, d: {}, g: [1], j: [] }                        # pre-existing [], {} and "" removed; emptied kept

DeeplyEnumerable::Hash.deep_compact_blanked(source)
# => { a: :b, d: { f: [] }, g: [1], h: {}, i: "" }          # emptied collections removed; pre-existing blanks kept

DeeplyEnumerable::Hash.deep_compact_blank(source)
# => { a: :b, g: [1] }                                      # every blank removed
```

Each method has an in-place `!` variant (`#deep_compact!`, `#deep_compact_blank!`,
etc.) that mutates the receiver and returns it, mirroring `#compact!`.

## Merging
```ruby
DeeplyEnumerable::Hash#reverse_deep_merge(other_hash)   # recursively fill in only the missing keys
DeeplyEnumerable::Hash#reverse_deep_merge!(other_hash)  # in place
```
`#deep_reverse_merge` / `#deep_reverse_merge!` are aliases.

## Usage
Call a class method to operate on a plain `Hash` or `Array`. The result is the
matching `DeeplyEnumerable` type (`Hash` returns a `DeeplyEnumerable::Hash`,
`Array` returns a `DeeplyEnumerable::Array`):
```ruby
DeeplyEnumerable::Hash.deep_compact_blank({ a: 1, b: nil, c: { d: nil } })
# => { a: 1 }

DeeplyEnumerable::Array.deep_compact([1, nil, [2, nil]])
# => [1, [2]]
```

Or extend the base `Hash` and `Array` classes (see *Installation*) and call the
methods directly:
```ruby
{ a: 1, b: nil }.deep_compact_blank   # => { a: 1 }
[1, nil, [nil]].deep_compact          # => [1, []]
```

## Upgrading from v1
v2 replaces the boolean arguments of `#deep_compact` with four named methods.
Map your old calls as follows:

| v1 call | v2 equivalent |
| --- | --- |
| `deep_compact` / `deep_compact(true, true)` | `deep_compact_blank` |
| `deep_compact(true, false)` | `deep_compact_blanked` |
| `deep_compact(false, true)` | `deep_compact_existing_blank` |
| `deep_compact(false, false)` | `deep_compact` |

⚠️ **`#deep_compact` changed meaning.** In v1, bare `deep_compact` defaulted to
the *most aggressive* behavior. In v2, `#deep_compact` removes **only nils**
(matching Ruby's `#compact`). If you relied on the old default, switch to
`#deep_compact_blank`.

⚠️ **Blank now means `blank?`, not just empty.** v1 only ever removed `nil` and
empty collections (`[]`, `{}`). The v2 `_blank` family also removes `false` and
blank strings (`""`, `" "`), matching Rails' `#compact_blank`. Blankness is
determined by an internal equivalent of ActiveSupport's `Object#blank?`, so the
gem still has **no ActiveSupport dependency**.

⚠️ **`default`/`default_proc` is not preserved.** v2 returns a freshly-built
`Hash`, so a default value or proc does not survive compaction (matching
`Hash#reject` and Rails' `#compact_blank`). v1 happened to keep it because it
mutated a `dup`. If you rely on auto-vivification, apply the default proc to the
compacted *result* rather than before compacting:

```ruby
# Fragile — the proc is dropped by compaction:
Hash.new { |h, k| h[k] = [] }.merge(value).deep_compact_blank

# Robust — compact first, then land the data in the proc-bearing Hash:
Hash.new { |h, k| h[k] = [] }.merge(value.deep_compact_blank)
```

## Installation
Add this line to your application's Gemfile:
```ruby
gem "deeply_enumerable"
```

or this line to mix the methods into the base `Hash` and `Array` classes:
```ruby
gem "deeply_enumerable", require: "base_extensions"
```

And then execute:
```bash
$ bundle install
```

Or install it yourself as:
```bash
$ gem install deeply_enumerable
```

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
