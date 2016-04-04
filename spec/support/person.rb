class Person < ActiveRecord::Base
  include Mindmapper

  has_many :books
end