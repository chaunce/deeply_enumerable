require_relative "enumerable"

module DeeplyEnumerable
  module HashExtension
    def self.included klass
      klass.class_eval do
        include DeeplyEnumerable::Enumerable
      end
    end

    def reverse_deep_merge!(other_hash)
      other_hash.each_pair do |current_key, other_value|
        this_value = self[current_key]

        self[current_key] = if this_value.is_a?(::Hash) && other_value.is_a?(::Hash)
          this_value = rebuild(this_value) unless this_value.respond_to?(:reverse_deep_merge)
          this_value.reverse_deep_merge(other_value)
        else
          key?(current_key) ? this_value : other_value
        end
      end

      self
    end
    alias_method :deep_reverse_merge!, :reverse_deep_merge!

    def reverse_deep_merge(other_hash)
      dup.reverse_deep_merge!(other_hash)
    end
    alias_method :deep_reverse_merge, :reverse_deep_merge

    # Recursively removes nil values, leaving every other value (including
    # already-blank ones such as "", [] and {}) untouched. This is the
    # recursive counterpart of Ruby's Hash#compact.
    # https://docs.ruby-lang.org/en/master/Hash.html#method-i-compact
    def deep_compact
      deep_compact_each(false, false)
    end

    # In-place variant of #deep_compact, mirroring Hash#compact!.
    def deep_compact!
      replace(deep_compact)
    end

    # Recursively removes nils and values that are already blank, but keeps
    # collections that only become blank as a result of compaction.
    def deep_compact_existing_blank
      deep_compact_each(false, true)
    end

    # In-place variant of #deep_compact_existing_blank.
    def deep_compact_existing_blank!
      replace(deep_compact_existing_blank)
    end

    # Recursively removes nils and collections that became blank through
    # compaction, but keeps values that were already blank.
    def deep_compact_blanked
      deep_compact_each(true, false)
    end

    # In-place variant of #deep_compact_blanked.
    def deep_compact_blanked!
      replace(deep_compact_blanked)
    end

    # Recursively removes every blank value (nil, false, "", " ", [], {}). This
    # is the recursive counterpart of Rails' Hash#compact_blank.
    # https://github.com/rails/rails/blob/main/activesupport/lib/active_support/core_ext/hash/keys.rb
    def deep_compact_blank
      deep_compact_each(true, true)
    end

    # In-place variant of #deep_compact_blank, mirroring Hash#compact_blank!.
    def deep_compact_blank!
      replace(deep_compact_blank)
    end

    private

    # Shared engine for the deep_compact family: rebuilds a hash of the same
    # class, recursively compacting each value and discarding the keys whose
    # value should be removed for the given combination of flags.
    def deep_compact_each(remove_emptied_elements, remove_empty_elements)
      each_with_object(self.class.new) do |(key, value), result|
        keep, value = deep_compact_element(value, remove_emptied_elements, remove_empty_elements)
        result[key] = value if keep
      end
    end
  end

  class Hash < ::Hash
    include DeeplyEnumerable::HashExtension

    class << self
      def deep_rebuild(object)
        check_object_class(object)
        new.tap { |deeply_enumerable_object| object.each { |key, value| deeply_enumerable_object[key] = rebuild(value) } }
      end

      def reverse_deep_merge(object)
        check_object_class(object)
        deep_rebuild(object).reverse_deep_merge
      end
      alias_method :deep_reverse_merge, :reverse_deep_merge
    end
  end
end
