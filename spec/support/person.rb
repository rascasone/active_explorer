require "./spec/support/introspection.rb"

class Person
  include Introspection

  attr_accessor :first_name
  attr_accessor :last_name

  attr_accessor :books_owned
end