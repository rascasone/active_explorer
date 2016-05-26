require "awesome_print" # TODO: Delete before going live.
require "active_explorer/version"
require 'graphviz'
require 'exploration'

module ActiveExplorer
  def explore(object_filter: [], association_filter: [], depth: 5)
    Exploration.new self, depth: depth, object_filter: object_filter, association_filter: association_filter
  end
end

# Explore object and print output to console.
def ex(object, object_filter: [], association_filter: [], depth: 5)
  exploration = ActiveExplorer::Exploration.new object, depth: depth, object_filter: object_filter, association_filter: association_filter
  exploration.to_console
  nil
end

# Explore object and print output to image file.
def exf(object, file_name = nil, object_filter: [], association_filter: [], depth: 5)
  file = file_name.nil? ? "#{object.class.name.downcase}_#{object.id}.png" : file_name

  puts "\nOutput file: #{file}\n"

  exploration = ActiveExplorer::Exploration.new object, depth: depth, object_filter: object_filter, association_filter: association_filter
  exploration.to_image file
  nil
end
