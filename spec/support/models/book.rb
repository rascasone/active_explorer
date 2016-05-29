class Book < ActiveRecord::Base
  include ActiveExplorer  #TODO: Remove this.

  belongs_to :author
  has_many :reviews
end