class Author < ActiveRecord::Base
  include Mindmapper

  has_many :books
end