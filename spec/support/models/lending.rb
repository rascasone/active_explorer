class Lending < ActiveRecord::Base
  belongs_to :person
  belongs_to :book
end