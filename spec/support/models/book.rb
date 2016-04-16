class Book < ActiveRecord::Base
  include Mindmapper

  belongs_to :author
end