# DeeplyEnumerable
Extend Enumerable objects with recursive methods

## Usage
Provides the following methods
```ruby
$ DeeplyEnumerable::Hash#reverse_deep_merge(DeeplyEnumerable::Hash)
$ DeeplyEnumerable::Hash#reverse_deep_merge!(DeeplyEnumerable::Hash)
$ DeeplyEnumerable::Hash#deep_compact
$ DeeplyEnumerable::Hash#deep_compact!

$ DeeplyEnumerable::Array#deep_compact
$ DeeplyEnumerable::Array#deep_compact!
```

Nested `Enumerable` objects will be converted into `DeeplyEnumerable` type objects during merge or compact operations to allow recursive method calls

Class methods may be used for base ruby enumerable objects, such as `Hash` or `Array` objects
```ruby
$ DeeplyEnumerable::Hash.deep_compact(Hash)
$ DeeplyEnumerable::Array.deep_compact(Array)
```

These methos will retrun a `DeeplyEnumerable` type object matching the object passed, e.g: `Array` will return a `DeeplyEnumerable::Array`

You may also extend base classes if you `require: 'base_extensions'` as described in *Installation*
```ruby
$ Hash#reverse_deep_merge(DeeplyEnumerable::Hash)
$ Hash#reverse_deep_merge!(DeeplyEnumerable::Hash)
$ Hash#deep_compact
$ Hash#deep_compact!

$ Array#deep_compact
$ Array#deep_compact!
```

## Installation
Add this line to your application's Gemfile:
```ruby
gem 'deeply_enumerable'
```

or this line to extend the base `Enumerable` classes:
```ruby
gem 'deeply_enumerable', require: 'base_extensions'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install deeply_enumerable
```

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
