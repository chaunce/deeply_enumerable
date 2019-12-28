require_relative 'enumerable'

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
          this_value = ebuild(this_value) unless this_value.respond_to?(:reverse_deep_merge)
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

    def deep_compact!(remove_emptied_elements = true, remove_empty_elements = remove_emptied_elements)
      each do |key, value|
        next if unenumerable_object?(value)

        value = rebuild(value) unless value.respond_to?(:reverse_deep_merge)
        compact_method = %i[deep_compact! deep_compact compact! compact].detect{ |m| value.respond_to?(m) }
        next unless compact_method

        original_empty = value.respond_to?(:empty?) ? value.empty? : value.respond_to?(:none?) ? value.none? : false
        compact_value = value.send(*[compact_method].concat(value.method(compact_method).parameters.collect { |_,param| binding.local_variable_get(param) } ).compact) || value
        compact_empty = compact_value.respond_to?(:empty?) ? compact_value.empty? : compact_value.respond_to?(:none?) ? compact_value.none? : false

        self[key] = (original_empty && remove_empty_elements) || (!original_empty && compact_empty && remove_emptied_elements) ? nil : compact_value
      end
      compact!

      self
    end

    def deep_compact(remove_emptied_elements = true, remove_empty_elements = remove_emptied_elements)
      dup.deep_compact!(remove_emptied_elements, remove_empty_elements)
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


