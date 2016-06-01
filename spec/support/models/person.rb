class Person < ActiveRecord::Base
  has_many :lendings
  has_many :books, through: :lendings
end