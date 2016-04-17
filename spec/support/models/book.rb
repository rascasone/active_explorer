class Book < ActiveRecord::Base
  include Mindmapper

  belongs_to :author
  has_many :reviews
end