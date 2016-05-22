module ActiveExplorer
  class Painter
    def initialize(exploration, file_path)
      @exploration = exploration
      @file_path = file_path
    end

    def paint
      paint_hash(@exploration.get_hash)
    end

    private

    def paint_hash(hash)
      filename = @file_path.split(File::SEPARATOR).last
      directory = @file_path.chomp filename

      create_directory directory unless directory.empty?



      # @graph = parent_node ? parent_node.root_graph : GraphViz.new(:G, :type => :digraph)
      # @graph = parent_node ? parent_node.root_graph : GraphViz.new(:G, :type => :digraph)


      # @graph.output(:png => file_path)
    end

    private

    def create_directory(directory)
      unless directory.empty? || File.directory?(directory)
        FileUtils.mkdir_p directory
      end
    end


    def add_edge
      @graph.add_edge(@parent_node, @self_node) if @parent_node
    end

    def add_node
      id = @object.id
      class_name = make_safe(@object.class.name)
      attributes = make_safe(@object.attributes.keys.join("\n"))
      values = make_safe(@object.attributes.values.collect { |val| make_short(val.to_s) }.join("\n"))

      @self_node = @graph.add_node("#{class_name}_#{id}", shape: "record", label: "{<f0> #{class_name}|{<f1> #{attributes}|<f2> #{values}}}")
    end

    # def write_object(object, level)
    #   class_name = object[:class_name]
    #   id = object[:attributes][:id]
    #   attributes = object[:attributes]
    #   error_message = object[:error_message]
    #
    #   attributes.delete :id
    #
    #   margin = '    ' * level
    #   margin[-2] = '->' if level > 0
    #
    #   puts "#{margin}#{class_name}(#{id}) #{attributes}"
    #
    #   if error_message.present?
    #     margin = '    ' * level
    #     puts "#{margin}(#{error_message})" if error_message.present?
    #   end
    #
    #   write_objects object[:subobjects], level + 1
    # end

    def write_objects(objects, level)
      objects.each do |object|
        write_object object, level
      end
    end
  end
end