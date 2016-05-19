require "awesome_print" # TODO: Delete before going live.
require "mindmapper/version"
require 'graphviz'

module Mindmapper
  def generate_mindmap(file_path: nil, associations_filter: [], max_depth: 5)
    raise TypeError, "Parameter 'associations_filter' must be Array but is #{associations_filter.class}." unless associations_filter.is_a? Array

    overview = Overview.new self, max_depth, associations_filter
    # overview.save_to_file file_path
    overview
  end

  private

  class Overview
    def initialize(object, max_depth, associations_filter, parent_object: nil)
      raise TypeError, "Parameter 'associations_filter' must be Array but is #{associations_filter.class}." unless associations_filter.is_a? Array
      raise ArgumentError, "Argument 'max_depth' must be at least 1." if max_depth < 1

      @object = object
      @max_depth = max_depth
      @associations_filter = associations_filter
      @associations = get_associtations
      @parent_object = parent_object
      @hash = {}

      puts "Level: #{max_depth}, object: #{@object.class.to_s} #{@object.id}, parent: #{parent_object&.class.to_s} #{parent_object&.id}"

      generate_hash
    end

    def get_hash
      @hash
    end

    private

    def generate_hash
      @hash[:class_name] = make_safe(@object.class.name)
      @hash[:attributes] = @object.attributes

      subobjects_hash = add_subobjects

      @hash[:subobjects] = subobjects_hash unless subobjects_hash.empty?
    end

    def add_subobjects
      results = []

      @associations.each do |association|
        if is_belongs_association?(association)
          subobject = subobjects_for(association)

          next if subobject.nil?

          puts "  @object: #{@object.class.to_s}, @subobject: #{subobject.class.to_s} Is parent?(#{subobject.class.to_s} #{subobject.id})#{is_parent?(subobject)}"
          unless is_parent?(subobject)
            hash = hash_from_object(subobject: subobject)
            results.push hash
          end
        elsif is_has_association?(association)
          subobjects = subobjects_for(association)

          next if subobjects.nil? || subobjects.empty?

          subobjects.each do |subobject|
            puts "  @object: #{@object.class.to_s}, @subobject: #{subobject.class.to_s} Is parent?(#{subobject.class.to_s} #{subobject.id})#{is_parent?(subobject)}"
            unless is_parent?(subobject)
              hash = hash_from_object(subobject: subobject) # TODO: Wouldn't it be better call this directly on the object? Monkey patch it.
              results.push hash
            end
          end
        end
      end

      results
    end

    def subobjects_for(association)
      begin
        subobjects = @object.send(association.name)
      rescue NameError => e
        association_type = is_has_association?(association) ? 'has_many' : 'belongs_to'
        add_error_hash("#{e.message} in #{association_type} :#{association.name}")
      end

      defined?(subobjects) ? subobjects : nil
    end

    def hash_from_object(subobject:)
      if @max_depth > 1
        # mindmap = Mindmap.new subobject, @max_depth - 1, @associations_filter, parent_object: @object
        overview = Overview.new subobject, @max_depth - 1, @associations_filter, parent_object: @object
        overview.get_hash
      end
    end

    def get_associtations
      @associations_filter.collect! { |association| association.to_s }

      associations = @object.class.reflections.collect do |reflection|
        reflection.second
      end

      associations.select! do |association|
        @associations_filter.include? association.plural_name.to_s
      end if @associations_filter.any?

      associations
    end

    def add_error_hash(message)
      id = @object.id
      class_name = @object.class.name

      @hash[:error_message] = "Error in #{class_name}(#{id}): #{message}"
      @hash[:class_name] = make_safe(@object.class.name)
      @hash[:attributes] = @object.attributes
    end

    def is_belongs_association?(association)
      association.is_a?(ActiveRecord::Reflection::BelongsToReflection)
    end

    def is_has_association?(association)
      association.is_a?(ActiveRecord::Reflection::HasManyReflection) ||
          association.is_a?(ActiveRecord::Reflection::HasOneReflection)
    end

    def is_parent?(object)
      object === @parent_object
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
  end
end
