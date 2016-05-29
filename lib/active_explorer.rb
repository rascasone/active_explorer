require "awesome_print" # TODO: Delete before going live.
require "active_explorer/version"
require 'graphviz'
require 'exploration'

module ActiveExplorer
  def explore(class_filter: [], association_filter: [], depth: 5)
    if depth <= 0
      puts "Depth must larger than or equal to 1."
      return nil
    end

    Exploration.new self, depth: depth, class_filter: class_filter, association_filter: association_filter
  end
end

# Explore object and print output to console.
def ex(object, class_filter: [], association_filter: [], depth: 5)
  exploration = ActiveExplorer::Exploration.new object, depth: depth, class_filter: class_filter, association_filter: association_filter
  exploration.to_console
  nil
end

# Explore object and print output to image file.
def exf(object, file_name = nil, class_filter: [], association_filter: [], depth: 5)
  file = file_name.nil? ? "#{object.class.name.downcase}_#{object.id}.png" : file_name

  puts "\nOutput file: #{file}\n"

  exploration = ActiveExplorer::Exploration.new object, depth: depth, class_filter: class_filter, association_filter: association_filter
  exploration.to_image file
  nil
end
