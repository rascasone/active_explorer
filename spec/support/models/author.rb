class Author < ActiveRecord::Base
  include ActiveExplorer  #TODO: Remove this.

  has_many :books
  has_many :reviews
end