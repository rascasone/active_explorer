require 'rspec'
require 'sqlite3'
require 'active_record'
require 'active_explorer'
require 'factory_girl'
require 'pry'

require_relative 'support/factory_girl'
require_relative 'support/db/sqlite3_connect'
require_relative 'support/db/schema'

Dir["./spec/support/models/*"].each {|file| require file }
Dir["./spec/support/factories/*"].each {|file| require file }