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
end

# Explore object and print output to image file.
def exf(object, object_filter: [], association_filter: [], depth: 5)
  file_name = "#{object.class.name.downcase}_#{object.id}.png"

  puts "\nOutput file: #{file_name}\n"

  exploration = ActiveExplorer::Exploration.new object, depth: depth, object_filter: object_filter, association_filter: association_filter
  exploration.to_image file_name
end
