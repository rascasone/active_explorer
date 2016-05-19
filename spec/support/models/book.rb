class Book < ActiveRecord::Base
  include ActiveExplorer

  belongs_to :author
  has_many :reviews
end