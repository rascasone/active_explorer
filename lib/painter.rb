module ActiveExplorer
  class Painter
    def initialize(exploration, file_path)
      @exploration = exploration
      @file_path = file_path
      @graph = GraphViz.new(:G, :type => :digraph)
    end

    def paint
      paint_object @exploration.get_hash, @graph, nil
      save_to_file
      @graph
    end

    private

    def paint_object(hash, graph, parent_node)
      node = add_node(hash, graph)
      add_edge(graph, parent_node, node, "  " + hash[:association]) unless parent_node.nil?

      paint_subobjects graph, node, hash[:subobjects] unless hash[:subobjects].empty?
    end

    def paint_subobjects(graph, parent_node, subhashes)
      subhashes.each do |hash|
        paint_object hash, graph, parent_node
      end
    end

    def add_node(hash, graph)
      id = hash[:attributes][:id]
      class_name = make_safe(hash[:class_name])
      attributes = make_safe(hash[:attributes].keys.join("\n"))
      values = make_safe(hash[:attributes].values.collect { |val| make_short(val.to_s) }.join("\n"))

      graph.add_node("#{class_name}_#{id}", shape: "record", label: "{<f0> #{class_name}|{<f1> #{attributes}|<f2> #{values}}}")
    end

    def add_edge(graph, parent_node, node, association)
      if association.include? "belongs_to"
        graph.add_edge(node, parent_node)
      else
        graph.add_edge(parent_node, node)
      end
    end

    def save_to_file
      filename = @file_path.split(File::SEPARATOR).last
      directory = @file_path.chomp filename

      create_directory directory unless directory.empty?

      @graph.output(:png => @file_path)
    end

    def create_directory(directory)
      unless directory.empty? || File.directory?(directory)
        FileUtils.mkdir_p directory
      end
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