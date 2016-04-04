require "awesome_print" # TODO: Delete before going live.
require "mindmapper/version"
require 'graphviz'

module Mindmapper
  def generate_mindmap(file_path:, associations: [])
    raise TypeError, "Parameter 'associations' must be Array but is #{associations.class}." unless associations.is_a? Array

    filename = file_path.split(File::SEPARATOR).last
    directory = file_path.chomp filename

    create_directory directory

    generete_graph file_path, associations
  end

  private

  def create_directory(directory)
    unless File.directory? directory
      FileUtils.mkdir_p directory
    end
  end

  def generete_graph(file_path, associations = [])
    raise TypeError, "Parameter 'associations' must be Array but is #{associations.class}." unless associations.is_a? Array

    g = GraphViz.new(:G, :type => :digraph)

    main_class_name = self.class.name
    main_attributes = self.attributes.keys.join("\n")
    main_values = self.attributes.values.join("\n")

    main_node = g.add_nodes("main_class", shape: "record", label: "{<f0> #{main_class_name}|{<f1> #{main_attributes}|<f2> #{main_values}}}")

    associations = associations.collect { |association| association.to_s }

    filtered_associations = self.class.reflections.collect do |association|
      (associations.include? association.first) ? association.second : nil
    end

    filtered_associations.compact!

    filtered_associations.each do |association|
      models = self.send(association.name)

      models.each do |model|
        model_class_name = model.class.name
        model_attributes = model.attributes.keys.join("\n")
        model_values = model.attributes.values.join("\n")

        model_node = g.add_nodes("#{model.class.name}_#{model.id}", shape: "record", label: "{<f0> #{model_class_name}|{<f1> #{model_attributes}|<f2> #{model_values}}}")

        g.add_edges(main_node, model_node)
      end
    end

    g.output(:png => file_path)
  end
end
