require 'writer'
require 'painter'

module ActiveExplorer
  class Exploration
    ASSOCIATION_FILTER_VALUES = [:has_many, :has_one, :belongs_to, :all]

    # Creates new exploration and generates exploration hash.
    #
    # @param association_filter [Array] Values of array: `:has_many`, `:has_one`, `:belongs_to`. When empty
    #   then it "follows previous association" (i.e. uses `:belongs_to` when previous assoc. was `:belongs_to` and
    #   uses `:has_xxx` when previous assoc. was `:has_xxx`). To always follow all associations you must specify
    #   all associations (e.g. uses `ActiveExplorer::Exploration::ASSOCIATION_FILTER_VALUES` as a value).
    #
    def initialize(object, depth: 10, object_filter: [], association_filter: [], parent_object: nil)
      raise TypeError, "Parameter 'object_filter' must be Array but is #{object_filter.class}." unless object_filter.is_a? Array
      raise TypeError, "Parameter 'association_filter' must be Array but is #{association_filter.class}." unless association_filter.is_a? Array
      raise TypeError, "Parameter 'association_filter' must only contain values #{ASSOCIATION_FILTER_VALUES.to_s[1..-2]}." unless association_filter.empty? || (association_filter & ASSOCIATION_FILTER_VALUES).any?
      raise ArgumentError, "Argument 'max_depth' must be at least 1." if depth <= 0

      @object = object
      @depth = depth
      @object_filter = object_filter.collect { |a| a.to_s }
      @association_filter = association_filter.include?(:all) ? ASSOCIATION_FILTER_VALUES : association_filter
      @associations = associtations(@object, @object_filter)
      @parent_object = parent_object

      @hash = { class_name: make_safe(@object.class.name),
                attributes: @object.attributes.symbolize_keys }

      @hash[:subobjects] = subobjects_hash(@object, @associations)
    end

    def get_hash
      @hash.deep_dup
    end

    def to_console
      Writer.new(self).write
    end

    def to_image(file, origin_as_root: false)
      Painter.new(self, file).paint(origin_as_root: origin_as_root)
    end

    private

    def subobjects_hash(object, associations)
      results = []

      associations.each do |association|
        association_type = association_type(association)

        next unless @association_filter.empty? || @association_filter.include?(association_type)

        if is_belongs_to_association?(association)
          subobject = subobjects_from_association(object, association)

          next if subobject.nil?

          unless is_parent?(subobject)
            if @depth > 1
              exploration = explore(subobject, parent_object: object, association_type: association_type)

              hash = exploration.get_hash
              hash[:association] = association_type.to_s

              results.push hash
            end
          end
        elsif is_has_many_association?(association) || is_has_one_association?(association)
          subobjects = subobjects_from_association(object, association)

          next if subobjects.nil? || subobjects.empty?

          subobjects.each do |subobject|

            unless is_parent?(subobject)
              if @depth > 1
                exploration = explore(subobject, parent_object: object, association_type: association_type) # TODO: Wouldn't it be better call this directly on the object? Monkey patch it.

                hash = exploration.get_hash
                hash[:association] = association_type.to_s

                results.push hash
              end
            end
          end
        end
      end

      results
    end

    def subobjects_from_association(object, association)
      subobjects = object.send(association.name)
      defined?(subobjects) && subobjects.present? ? subobjects : nil

    rescue NameError, ActiveRecord::StatementInvalid, ActiveRecord::RecordNotFound => e
      association_type = is_has_many_association?(association) ? 'has_many' : 'belongs_to'
      add_error_hash("#{e.message} in #{association_type} :#{association.name}")
      nil
    end

    def explore(object, parent_object:, association_type:)
      association_filter = if @association_filter.any?
                             @association_filter
                           elsif association_type == :belongs_to
                             [:belongs_to]
                           else
                             [:has_many, :has_one]
                           end

      Exploration.new object, depth: @depth - 1, object_filter: @object_filter, association_filter: association_filter, parent_object: parent_object
    end

    def associtations(object, filter)
      associations = object.class.reflections.collect do |reflection|
        reflection.second
      end

      if filter.any?
        associations.select! do |association|
          filter.include? association.plural_name.to_s
        end
      end

      associations
    end

    def add_error_hash(message)
      @hash[:class_name] = make_safe(@object.class.name)
      @hash[:attributes] = @object.attributes.symbolize_keys

      @hash[:error_message] = "Error in #{@object.class.name}(#{@object.id}): #{message}"
    end

    def make_short(text)
      text.length < 70 ? text : text[0..70] + " (...)"
    end

    # Replace characters that conflict with DOT language (used in GraphViz).
    # These: `{`, `}`, `<`, `>`, `|`, `\`
    #
    def make_safe(text)
      text.tr('{}<>|\\', '')
    end

    def is_belongs_to_association?(association)
      association.is_a?(ActiveRecord::Reflection::BelongsToReflection)
    end

    def is_has_many_association?(association)
      association.is_a?(ActiveRecord::Reflection::HasManyReflection)
    end

    def is_has_one_association?(association)
      association.is_a?(ActiveRecord::Reflection::HasOneReflection)
    end

    def is_parent?(object)
      object === @parent_object
    end

    def association_type(association)
      if association.is_a?(ActiveRecord::Reflection::HasManyReflection)
        :has_many
      elsif association.is_a?(ActiveRecord::Reflection::HasOneReflection)
        :has_one
      elsif association.is_a?(ActiveRecord::Reflection::BelongsToReflection)
        :belongs_to
      end
    end
  end
end