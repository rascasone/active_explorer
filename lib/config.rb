module ActiveExplorer
  class Config
    cattr_accessor :attribute_filter
    cattr_accessor :class_filter
    cattr_accessor :association_filter
    cattr_accessor :attribute_limit
  end
end
