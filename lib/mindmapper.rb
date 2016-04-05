require "awesome_print" # TODO: Delete before going live.
require "mindmapper/version"
require 'graphviz'

module Mindmapper
  def generate_mindmap(file_path:, associations_filter: [], max_depth: 3)
    raise TypeError, "Parameter 'associations_filter' must be Array but is #{associations_filter.class}." unless associations_filter.is_a? Array

    mindmap = Mindmap.new self, max_depth, associations_filter
    mindmap.save_to_file file_path
  end

  private

  class Mindmap
    def initialize(object, max_depth, associations_filter, parent_node: nil)
      raise TypeError, "Parameter 'associations_filter' must be Array but is #{associations_filter.class}." unless associations_filter.is_a? Array

      return false if max_depth == 0

      @object = object
      @max_depth = max_depth
      @associations_filter = associations_filter
      @associations = get_associtations
      @graph = parent_node ? parent_node.root_graph : GraphViz.new(:G, :type => :digraph)
      @parent_node = parent_node

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
        @associations_filter.include? association.name.to_s
      end

      associations
    end

    def generate_graph
      node = add_node

      @graph.add_edge(@parent_node, node) if @parent_node

      add_subnodes node
    end

    def add_node
      id = @object.id
      class_name = @object.class.name
      attributes = @object.attributes.keys.join("\n")
      values = @object.attributes.values.join("\n")

      @graph.add_node("#{class_name}_#{id}", shape: "record", label: "{<f0> #{class_name}|{<f1> #{attributes}|<f2> #{values}}}")
    end

    def add_subnodes(node)
      @associations.each do |association|
        models = @object.send(association.name)

        models.each do |model|
          mindmap = Mindmap.new model, @max_depth - 1, @associations_filter, parent_node: node
          @graph = mindmap.graph
        end
      end
    end
  end
end
