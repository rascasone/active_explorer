require "awesome_print" # TODO: Delete before going live.
require "active_explorer/version"
require 'graphviz'
require 'exploration'

# Explore object and print output to console.
def ex(object, class_filter: [], attribute_filter: [], association_filter: [], depth: 5)
  if depth <= 0
    puts "Depth must larger than or equal to 1."
    return
  end

  if object.nil?
    puts "Object to be explored is `nil`."
    return
  end

  exploration = ActiveExplorer::Exploration.new object, depth: depth, class_filter: class_filter, attribute_filter: attribute_filter, association_filter: association_filter
  exploration.to_console
  nil
end

# Explore object and print output to image file.
def exf(object, file_name = nil, class_filter: [], attribute_filter: [], association_filter: [], depth: 5)
  if depth <= 0
    puts "Depth must larger than or equal to 1."
    return
  end

  if object.nil?
    puts "Object to be explored is `nil`."
    return
  end

  file = file_name.nil? ? "#{object.class.name.downcase}_#{object.id}.png" : file_name

  puts "\nOutput file: #{file}\n"

  exploration = ActiveExplorer::Exploration.new object, depth: depth, class_filter: class_filter, attribute_filter: attribute_filter, association_filter: association_filter
  exploration.to_image file
  nil
end
