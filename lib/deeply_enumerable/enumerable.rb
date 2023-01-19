module DeeplyEnumerable
  module Enumerable
    UNENUMERABLE = ["ActiveRecord::Relation", "Range"]

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

      def deep_compact(object, remove_emptied_elements = true, remove_empty_elements = remove_emptied_elements)
        check_object_class(object)
        deep_rebuild(object).deep_compact(remove_emptied_elements, remove_empty_elements)
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
  end
end
