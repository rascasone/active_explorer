require 'rspec'
require 'active_record'
require 'mindmapper'

require './spec/support/person' # TODO: Load all support classes by command.
require './spec/support/book'

ActiveRecord::Base.establish_connection(
    :adapter  => 'mysql',
    :database => 'mindmapper_test',
    :username => 'root',
    :password => 'root',
    :host     => 'localhost')