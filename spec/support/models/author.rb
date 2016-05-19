class Author < ActiveRecord::Base
  include ActiveExplorer

  has_many :books
  has_many :reviews
end