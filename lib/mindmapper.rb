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
    def initialize(object, max_depth, associations_filter)
      raise TypeError, "Parameter 'associations_filter' must be Array but is #{associations_filter.class}." unless associations_filter.is_a? Array

      @object = object
      @max_depth = max_depth
      @associations = get_associtations(associations_filter)

      generate_graph
    end

    def save_to_file(file_path)
      filename = file_path.split(File::SEPARATOR).last
      directory = file_path.chomp filename

      create_directory directory

      @graph.output(:png => file_path)
    end

    private

    def create_directory(directory)
      unless File.directory? directory
        FileUtils.mkdir_p directory
      end
    end

    def get_associtations(associations_filter)
      associations_filter.collect! { |association| association.to_s }

      associations = @object.class.reflections.collect do |reflection|
        reflection.second
      end

      associations.select! do |association|
        associations_filter.include? association.name.to_s
      end

      associations
    end

    # Empty
    # def generate_graph(file_path, current_depth = 0, max_depth = 3, associations = [] )
    def generate_graph
      @graph = GraphViz.new(:G, :type => :digraph)

      main_class_name = @object.class.name
      main_attributes = @object.attributes.keys.join("\n")
      main_values = @object.attributes.values.join("\n")

      @main_node = @graph.add_nodes("main_class", shape: "record", label: "{<f0> #{main_class_name}|{<f1> #{main_attributes}|<f2> #{main_values}}}")

      add_subnodes
    end

    def add_subnodes
      @associations.each do |association|
        models = @object.send(association.name)

        models.each do |model|
          model_class_name = model.class.name
          model_attributes = model.attributes.keys.join("\n")
          model_values = model.attributes.values.join("\n")

          model_node = @graph.add_nodes("#{model.class.name}_#{model.id}", shape: "record", label: "{<f0> #{model_class_name}|{<f1> #{model_attributes}|<f2> #{model_values}}}")

          @graph.add_edges(@main_node, model_node)
        end
      end
    end
  end
end
