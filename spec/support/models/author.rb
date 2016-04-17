class Author < ActiveRecord::Base
  include Mindmapper

  has_many :books
  has_many :reviews
end