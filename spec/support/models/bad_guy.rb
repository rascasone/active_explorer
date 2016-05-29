class BadGuy < ActiveRecord::Base
  include ActiveExplorer  #TODO: Remove this.

  has_many :bad_thoughts  # Table `bad_thoughts` does not exist on purpose.
end