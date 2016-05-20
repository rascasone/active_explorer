module ActiveExplorer
  class Writer
    def initialize(exploration)
      @exploration = exploration
    end

    def write
      puts "\n"
      write_object(@exploration.to_hash, 0)
      puts "\n"
    end

    private

    def write_object(object, level)
      class_name = object[:class_name]
      id = object[:attributes][:id]
      attributes = object[:attributes]
      error_message = object[:error_message]

      attributes.delete :id

      margin = '    ' * level
      margin[-2] = '->' if level > 0

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
