class Book < ActiveRecord::Base
  belongs_to :author
  has_many :reviews
  has_many :lendings
  has_many :lendees, through: :lendings, source: :person
end