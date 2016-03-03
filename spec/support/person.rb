require "./spec/support/introspection.rb"

class Person < ActiveRecord::Base
  # include Introspection
  include MindMapper

  # attr_accessor :first_name
  # attr_accessor :last_name
  #
  # attr_accessor :books_owned
end