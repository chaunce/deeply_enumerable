require_relative "enumerable"

module DeeplyEnumerable
  module ArrayExtension
    def self.included klass
      klass.class_eval do
        include DeeplyEnumerable::Enumerable
      end
    end

    # Recursively removes nil elements, leaving every other element (including
    # already-blank ones such as "", [] and {}) untouched. This is the
    # recursive counterpart of Ruby's Array#compact.
    # https://docs.ruby-lang.org/en/master/Array.html#method-i-compact
    def deep_compact
      deep_compact_each(false, false)
    end

    # In-place variant of #deep_compact, mirroring Array#compact!.
    def deep_compact!
      replace(deep_compact)
    end

    # Recursively removes nils and elements that are already blank, but keeps
    # collections that only become blank as a result of compaction.
    def deep_compact_existing_blank
      deep_compact_each(false, true)
    end

    # In-place variant of #deep_compact_existing_blank.
    def deep_compact_existing_blank!
      replace(deep_compact_existing_blank)
    end

    # Recursively removes nils and collections that became blank through
    # compaction, but keeps elements that were already blank.
    def deep_compact_blanked
      deep_compact_each(true, false)
    end

    # In-place variant of #deep_compact_blanked.
    def deep_compact_blanked!
      replace(deep_compact_blanked)
    end

    # Recursively removes every blank element (nil, false, "", " ", [], {}).
    # This is the recursive counterpart of Rails' Array#compact_blank.
    # https://github.com/rails/rails/blob/main/activesupport/lib/active_support/core_ext/enumerable.rb
    def deep_compact_blank
      deep_compact_each(true, true)
    end

    # In-place variant of #deep_compact_blank, mirroring Array#compact_blank!.
    def deep_compact_blank!
      replace(deep_compact_blank)
    end

    private

    # Shared engine for the deep_compact family: rebuilds an array of the same
    # class, recursively compacting each element and discarding the ones that
    # should be removed for the given combination of flags.
    def deep_compact_each(remove_emptied_elements, remove_empty_elements)
      each_with_object(self.class.new) do |element, result|
        keep, element = deep_compact_element(element, remove_emptied_elements, remove_empty_elements)
        result.push(element) if keep
      end
    end
  end

  class Array < ::Array
    include DeeplyEnumerable::ArrayExtension
  end
end
