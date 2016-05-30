class Book < ActiveRecord::Base
  belongs_to :author
  has_many :reviews
end