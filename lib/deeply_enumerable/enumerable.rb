module DeeplyEnumerable
  module Enumerable
    # Collection-like objects that should be treated as opaque elements rather
    # than recursed into during deep operations.
    UNENUMERABLE = ["ActiveRecord::Relation", "Range"]

    # Whitespace-only strings are considered blank, mirroring ActiveSupport.
    # https://github.com/rails/rails/blob/main/activesupport/lib/active_support/core_ext/object/blank.rb
    BLANK_RE = /\A[[:space:]]*\z/

    def self.included(klass)
      klass.extend(ClassMethods)
    end

    module ClassMethods
      def rebuild(object)
        deeply_enumerable_class_name = DeeplyEnumerable.constants(false).detect do |const|
          deeply_enumerable_const = DeeplyEnumerable.const_get(const)
          deeply_enumerable_const.respond_to?(:superclass) ? !!object.is_a?(deeply_enumerable_const.superclass) : false
        end

        return object if deeply_enumerable_class_name.nil?

        deeply_enumerable_class = DeeplyEnumerable.const_get(deeply_enumerable_class_name)
        deeply_enumerable_class.respond_to?(:deep_rebuild) ? deeply_enumerable_class.deep_rebuild(object) : object
      end

      def deep_rebuild(object)
        check_object_class(object)
        new.tap { |deeply_enumerable_object| object.each { |value| deeply_enumerable_object.push(rebuild(value)) } }
      end

      # Recursively removes nil values.
      # Mirrors Ruby's Array#compact / Hash#compact.
      def deep_compact(object)
        deep_rebuild(object).deep_compact
      end

      # Recursively removes nils and values that are already blank, while
      # keeping collections that only become blank as a result of compaction.
      def deep_compact_existing_blank(object)
        deep_rebuild(object).deep_compact_existing_blank
      end

      # Recursively removes nils and collections that became blank through
      # compaction, while keeping values that were already blank.
      def deep_compact_blanked(object)
        deep_rebuild(object).deep_compact_blanked
      end

      # Recursively removes every blank value.
      # Mirrors Rails' Enumerable#compact_blank.
      def deep_compact_blank(object)
        deep_rebuild(object).deep_compact_blank
      end

      def unenumerable
        @unenumerable ||= UNENUMERABLE.map { |unenumerable| unenumerable.constantize rescue nil }.compact
      end

      private

      def check_object_class(object)
        raise TypeError, "object must be a #{superclass.name}" unless object.kind_of?(superclass)
      end
    end

    def rebuild(object)
      self.class.rebuild(object)
    end

    def unenumerable_object?(object)
      self.class.unenumerable.any? { |unenumerable_klass| object.is_a?(unenumerable_klass) }
    end

    private

    # Decides what to do with a single element during deep compaction and
    # returns [keep?, element], where +element+ may be a rebuilt/compacted
    # copy.
    #
    # nil is always dropped. Nested enumerables are compacted recursively, then
    # dropped if they were already blank (+remove_empty_elements+) or only
    # became blank through compaction (+remove_emptied_elements+).
    # Non-enumerable elements are dropped only when already blank and
    # +remove_empty_elements+ is set.
    def deep_compact_element(element, remove_emptied_elements, remove_empty_elements)
      return [false, element] if element.nil?

      element = rebuild(element) unless unenumerable_object?(element) || element.respond_to?(:deep_compact_each, true)

      if !unenumerable_object?(element) && element.respond_to?(:deep_compact_each, true)
        blank_before = deeply_blank?(element)
        element = element.send(:deep_compact_each, remove_emptied_elements, remove_empty_elements)
        keep = !((blank_before && remove_empty_elements) ||
                 (!blank_before && remove_emptied_elements && deeply_blank?(element)))
        [keep, element]
      else
        [!(remove_empty_elements && deeply_blank?(element)), element]
      end
    end

    # Internal equivalent of ActiveSupport's Object#blank? (with
    # String#blank?), implemented here so the gem needs no ActiveSupport
    # dependency.
    # https://github.com/rails/rails/blob/main/activesupport/lib/active_support/core_ext/object/blank.rb
    def deeply_blank?(value)
      return value.match?(BLANK_RE) if value.is_a?(::String)

      value.respond_to?(:empty?) ? !!value.empty? : !value
    end
  end
end
