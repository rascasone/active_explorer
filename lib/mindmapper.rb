require "awesome_print" # TODO: Delete before going live.
require "mindmapper/version"
require 'graphviz'

module Mindmapper
  def generate_mindmap(file_path:, associations_filter: [], max_depth: 5)
    raise TypeError, "Parameter 'associations_filter' must be Array but is #{associations_filter.class}." unless associations_filter.is_a? Array

    mindmap = Mindmap.new self, max_depth, associations_filter
    mindmap.save_to_file file_path
    mindmap
  end

  private

  class Mindmap
    def initialize(object, max_depth, associations_filter, parent_node: nil, parent_object: nil)
      raise TypeError, "Parameter 'associations_filter' must be Array but is #{associations_filter.class}." unless associations_filter.is_a? Array
      raise ArgumentError, "Argument 'max_depth' must be at least 1." if max_depth < 1

      @object = object
      @max_depth = max_depth
      @associations_filter = associations_filter
      @associations = get_associtations
      @graph = parent_node ? parent_node.root_graph : GraphViz.new(:G, :type => :digraph)
      @parent_node = parent_node
      @parent_object = parent_object

      puts "Level: #{max_depth}, object: #{@object.class.to_s} #{@object.id}, parent: #{parent_object&.class.to_s} #{parent_object&.id}"

      generate_graph
    end

    def save_to_file(file_path)
      filename = file_path.split(File::SEPARATOR).last
      directory = file_path.chomp filename

      create_directory directory

      @graph.output(:png => file_path)
    end

    def graph
      @graph
    end

    private

    def create_directory(directory)
      unless File.directory? directory
        FileUtils.mkdir_p directory
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

    def generate_graph
      add_node
      add_edge
      add_subnodes
    end

    def add_edge
      @graph.add_edge(@parent_node, @self_node) if @parent_node
    end

    def add_node
      id = @object.id
      class_name = @object.class.name
      attributes = @object.attributes.keys.join("\n")
      values = @object.attributes.values.join("\n")

      @self_node = @graph.add_node("#{class_name}_#{id}", shape: "record", label: "{<f0> #{class_name}|{<f1> #{attributes}|<f2> #{values}}}")
    end

    def add_subnodes
      @associations.each do |association|
        if is_belongs_association?(association)
          subobject = subobjects_for(association)

          next if subobject.nil?

          puts "  @object: #{@object.class.to_s}, @subobject: #{subobject.class.to_s} Is parent?(#{subobject.class.to_s} #{subobject.id})#{is_parent?(subobject)}"
          add_subobject_to_graph(subobject: subobject, node: @self_node) unless is_parent?(subobject)
        elsif is_has_association?(association)
          subobjects = subobjects_for(association)

          next if subobjects.nil? || subobjects.empty?

          subobjects.each do |subobject|
            puts "  @object: #{@object.class.to_s}, @subobject: #{subobject.class.to_s} Is parent?(#{subobject.class.to_s} #{subobject.id})#{is_parent?(subobject)}"
            add_subobject_to_graph(subobject: subobject, node: @self_node) unless is_parent?(subobject)
          end
        end
      end
    end

    def subobjects_for(association)
      begin
        subobjects = @object.send(association.name)
      rescue NameError => e
        association_type = is_has_association?(association) ? 'has_many' : 'belongs_to'
        add_error_node("#{e.message} in #{association_type} :#{association.name}")
      end

      defined?(subobjects) ? subobjects : nil
    end

    def add_error_node(msg)
      id = @object.id
      class_name = @object.class.name
      @randomizer ||= Random.new
      error_id = @randomizer.rand

      error_node = @graph.add_node("#{class_name}_#{id}_error_#{error_id}",
                                   shape: "record",
                                   label: "{Error in #{class_name}(#{id}) | {#{msg}}}")

      @graph.add_edge(@self_node, error_node) if @self_node
    end

    def is_belongs_association?(association)
      association.is_a?(ActiveRecord::Reflection::BelongsToReflection)
    end

    def is_has_association?(association)
      association.is_a?(ActiveRecord::Reflection::HasManyReflection) ||
          association.is_a?(ActiveRecord::Reflection::HasOneReflection)
    end

    def add_subobject_to_graph(subobject:, node:)
      if @max_depth > 1
        mindmap = Mindmap.new subobject, @max_depth - 1, @associations_filter, parent_node: node, parent_object: @object

        @graph = mindmap.graph
      end
    end

    def is_parent?(object)
      object === @parent_object
    end
  end
end
