require "deeply_enumerable"

Hash.send(:include, DeeplyEnumerable::HashExtension)
Array.send(:include, DeeplyEnumerable::ArrayExtension)
