require "awesome_print" # TODO: Delete before going live.
require "active_explorer/version"
require 'graphviz'
require 'exploration'

module ActiveExplorer
  def explore(object_filter: [], association_filter: [], depth: 5)
    Exploration.new self, depth: depth, object_filter: object_filter, association_filter: association_filter
  end
end

def ex(object, object_filter: [], association_filter: [], depth: 5)
  exploration = ActiveExplorer::Exploration.new object, depth: depth, object_filter: object_filter, association_filter: association_filter
  exploration.to_console
end

def exf(object, object_filter: [], association_filter: [], depth: 5)
  exploration = ActiveExplorer::Exploration.new object, depth: depth, object_filter: object_filter, association_filter: association_filter
  exploration.to_image "#{object.class.name.downcase}_#{object.id}.png"
end
