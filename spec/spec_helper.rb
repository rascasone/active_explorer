require 'rspec'
require 'active_record'
require 'active_explorer'
require 'factory_girl'
require 'pry'

require_relative 'support/factory_girl'

Dir["./spec/support/models/*"].each {|file| require file }
Dir["./spec/support/factories/*"].each {|file| require file }

ActiveRecord::Base.establish_connection(
    :adapter  => 'mysql',
    :database => 'active_explorer_test',
    :username => 'root',
    :password => 'root',
    :host     => 'localhost')