require 'writer'
require 'painter'

module ActiveExplorer
  class Exploration
    def initialize(object, max_depth, filter, parent_object: nil)
      raise TypeError, "Parameter 'associations_filter' must be Array but is #{filter.class}." unless filter.is_a? Array
      raise ArgumentError, "Argument 'max_depth' must be at least 1." if max_depth <= 0

      @object = object
      @max_depth = max_depth
      @filter = filter.collect { |a| a.to_s }
      @associations = associtations(@object, @filter)
      @parent_object = parent_object

      @hash = { class_name: make_safe(@object.class.name),
                attributes: @object.attributes.symbolize_keys }

      @hash[:subobjects] = subobjects_hash(@object, @associations)
    end

    def get_hash
      @hash
    end

    def to_console
      Writer.new(self).write
    end

    def to_image(file)
      Painter.new(self, file).paint
    end

    private

    def subobjects_hash(object, associations)
      results = []

      associations.each do |association|
        if is_belongs_to_association?(association)
          subobject = subobjects(object, association)

          next if subobject.nil?

          unless is_parent?(subobject)
            hash = hash_from(subobject, parent_object: object)
            results.push hash unless hash.nil?
          end
        elsif is_has_many_association?(association) || is_has_one_association?(association)
          subobjects = subobjects(object, association)

          next if subobjects.nil? || subobjects.empty?

          subobjects.each do |subobject|

            unless is_parent?(subobject)
              hash = hash_from(subobject, parent_object: object) # TODO: Wouldn't it be better call this directly on the object? Monkey patch it.
              results.push hash unless hash.nil?
            end
          end
        end
      end

      results
    end

    def subobjects(object, association)
      begin
        subobjects = object.send(association.name)
      rescue NameError => e
        association_type = is_has_many_association?(association) ? 'has_many' : 'belongs_to'
        add_error_hash("#{e.message} in #{association_type} :#{association.name}")
      end

      defined?(subobjects) && subobjects.present? ? subobjects : nil
    end

    def hash_from(object, parent_object:)
      lower_depth = @max_depth - 1

      if lower_depth >= 1
        overview = Exploration.new object, lower_depth, @filter, parent_object: parent_object
        overview.get_hash
      end
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
  end
end