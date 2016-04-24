require 'rspec'
require 'active_record'
require 'mindmapper'
require 'factory_girl'

require_relative 'support/factory_girl'

Dir["./spec/support/models/*"].each {|file| require file }
Dir["./spec/support/factories/*"].each {|file| require file }

ActiveRecord::Base.establish_connection(
    :adapter  => 'mysql',
    :database => 'mindmapper_test',
    :username => 'root',
    :password => 'root',
    :host     => 'localhost')