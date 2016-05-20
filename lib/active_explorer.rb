require "awesome_print" # TODO: Delete before going live.
require "active_explorer/version"
require 'graphviz'
require 'exploration'

module ActiveExplorer
  def explore(filter: [], max_depth: 5)
    Exploration.new self, max_depth, filter
  end
end
