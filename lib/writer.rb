module ActiveExplorer
  class Writer
    def initialize(exploration)
      @exploration = exploration
    end

    def write
      exploration_hash = @exploration.get_hash

      puts "\nExplored #{exploration_hash[:class_name]}(#{exploration_hash[:attributes][:id]}):\n\n"
      write_object(exploration_hash)
      puts "\n"
    end

    private

    def write_object(object, level = 0)
      class_name = object[:class_name]
      id = object[:attributes][:id]
      attributes = object[:attributes]
      error_message = object[:error_message]

      attributes.delete :id

      margin = '    ' * level

      if level > 0
        margin[-2] = '->'
        margin += object[:assocation] == :belongs_to ? 'belongs to' : 'has '
      end

      puts "#{margin}#{class_name}(#{id}) #{attributes}"

      if error_message.present?
        margin = '    ' * level
        puts "#{margin}(#{error_message})" if error_message.present?
      end

      write_objects object[:subobjects], level + 1
    end

    def write_objects(objects, level)
      objects.each do |object|
        write_object object, level
      end
    end
  end
end
