require 'rubygems'
require 'test/unit'

require 'rails'
require 'active_support'
require 'active_record'

ENV['RAILS_ENV'] = 'test'

require "#{File.dirname(__FILE__)}/../init"

config = YAML.load(File.read('test/database.yml'))
ActiveRecord::Base.configurations = {'test' => config['sqlite3']}
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
ActiveRecord::Migration.verbose = false
load(File.dirname(__FILE__) + "/schema.rb")
