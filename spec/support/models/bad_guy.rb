class BadGuy < ActiveRecord::Base
  has_many :bad_thoughts  # Table `bad_thoughts` does not exist on purpose.
end