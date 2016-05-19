require "awesome_print" # TODO: Delete before going live.
require "active_explorer/version"
require 'graphviz'
require 'exploration'

module ActiveExplorer
  def explore(file_path: nil, filter: [], max_depth: 5)
    exploration = Exploration.new self, max_depth, filter
    # overview.save_to_file file_path
    exploration.as_hash
  end
end
