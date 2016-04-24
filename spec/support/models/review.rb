class Review < ActiveRecord::Base
  include Mindmapper

  validates :stars, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }

  belongs_to :book
  belongs_to :author
end