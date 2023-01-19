require_relative "enumerable"

module DeeplyEnumerable
  module ArrayExtension
    def self.included klass
      klass.class_eval do
        include DeeplyEnumerable::Enumerable
      end
    end

    def deep_compact!(remove_emptied_elements = true, remove_empty_elements = remove_emptied_elements)
      each.with_index do |value, index|
        next if unenumerable_object?(value)

        value = rebuild(value) unless value.respond_to?(:reverse_deep_merge)
        compact_method = %i[deep_compact! deep_compact compact! compact].detect{ |m| value.respond_to?(m) }
        next unless compact_method

        original_empty = value.respond_to?(:empty?) ? value.empty? : value.respond_to?(:none?) ? value.none? : false
        compact_value = value.send(*[compact_method].concat(value.method(compact_method).parameters.collect { |_,param| binding.local_variable_get(param) } ).compact) || value
        compact_empty = compact_value.respond_to?(:empty?) ? compact_value.empty? : compact_value.respond_to?(:none?) ? compact_value.none? : false

        if (original_empty && remove_empty_elements) || (!original_empty && compact_empty && remove_emptied_elements)
          self.delete_at(index)
        else
          self[index] = compact_value
        end
      end
      compact!

      self
    end

    def deep_compact(remove_emptied_elements = true, remove_empty_elements = remove_emptied_elements)
      dup.deep_compact!(remove_emptied_elements, remove_empty_elements)
    end
  end

  class Array < ::Array
    include DeeplyEnumerable::ArrayExtension
  end
end
