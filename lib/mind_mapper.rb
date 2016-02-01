require "mindmapper/version"
require 'graphviz'

module MindMapper
  def generate_mindmap(file_path)
    filename = file_path.split(File::SEPARATOR).last
    directory = file_path.chomp filename

    create_directory directory

    generete_graph file_path
  end

  private

  def create_directory(directory)
    unless File.directory? directory
      FileUtils.mkdir_p directory
    end
  end

  def generete_graph(file_path)
    g = GraphViz.new(:G, :type => :digraph)

    hello = g.add_nodes("Hello")
    world = g.add_nodes("World")

    g.add_edges(hello, world)

    g.output(:png => file_path)
  end
end
