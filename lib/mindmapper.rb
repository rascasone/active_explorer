require "awesome_print" # TODO: Delete before going live.
require "mindmapper/version"
require 'graphviz'

module Mindmapper
  def generate_mindmap(file_path: nil, associations_filter: [], max_depth: 5)
    raise TypeError, "Parameter 'associations_filter' must be Array but is #{associations_filter.class}." unless associations_filter.is_a? Array

    overview = Overview.new self, max_depth, associations_filter
    # overview.save_to_file file_path
    overview.as_hash
  end

  private

  class Overview
    def initialize(object, max_depth, associations_filter, parent_object: nil)
      raise TypeError, "Parameter 'associations_filter' must be Array but is #{associations_filter.class}." unless associations_filter.is_a? Array
      raise ArgumentError, "Argument 'max_depth' must be at least 1." if max_depth <= 0

      @object = object
      @max_depth = max_depth
      @associations_filter = associations_filter.collect { |a| a.to_s }
      @associations = associtations(@object, @associations_filter)
      @parent_object = parent_object

      # puts "Level: #{max_depth}, object: #{@object.class.to_s} #{@object.id}, parent: #{parent_object&.class.to_s} #{parent_object&.id}"

      @hash = { class_name: make_safe(@object.class.name),
                attributes: @object.attributes }

      @hash[:subobjects] = subobjects_hash(@object, @associations)
    end

    def as_hash
      @hash
    end

    private

    def subobjects_hash(object, associations)
      results = []

      associations.each do |association|
        if is_belongs_to_association?(association)
          subobject = subobjects(object, association)

          next if subobject.nil?

          # puts "  @object: #{@object.class.to_s}, @subobject: #{subobject.class.to_s} Is parent?(#{subobject.class.to_s} #{subobject.id})#{is_parent?(subobject)}"

          unless is_parent?(subobject)
            hash = hash_from(subobject, parent_object: object)
            results.push hash
          end
        elsif is_has_many_association?(association) || is_has_one_association?(association)
          subobjects = subobjects(object, association)

          next if subobjects.nil? || subobjects.empty?

          subobjects.each do |subobject|

            # puts "  @object: #{@object.class.to_s}, @subobject: #{subobject.class.to_s} Is parent?(#{subobject.class.to_s} #{subobject.id})#{is_parent?(subobject)}"

            unless is_parent?(subobject)
              hash = hash_from(subobject, parent_object: object) # TODO: Wouldn't it be better call this directly on the object? Monkey patch it.
              results.push hash
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

      defined?(subobjects) ? subobjects : nil
    end

    def hash_from(object, parent_object:)
      lower_depth = @max_depth - 1

      if lower_depth >= 1
        overview = Overview.new object, lower_depth, @associations_filter, parent_object: parent_object
        overview.as_hash
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
      id = @object.id
      class_name = @object.class.name

      @hash[:error_message] = "Error in #{class_name}(#{id}): #{message}"
      @hash[:class_name] = make_safe(@object.class.name)
      @hash[:attributes] = @object.attributes
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
