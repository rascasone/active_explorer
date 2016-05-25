require "awesome_print" # TODO: Delete before going live.
require "active_explorer/version"
require 'graphviz'
require 'exploration'

module ActiveExplorer
  def explore(object_filter: [], association_filter: [], depth: 5)
    Exploration.new self, depth: depth, object_filter: object_filter, association_filter: association_filter
  end
end
