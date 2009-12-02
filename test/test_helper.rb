require 'rubygems'
require 'test/unit'
require 'active_support'
require 'active_support/test_case'
require 'active_record'
require 'active_record/fixtures'
require 'models'

ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/log/test.log")
ActiveRecord::Base.configurations = YAML::load(File.open(File.dirname(__FILE__) + "/database.yml"))
ActiveRecord::Base.establish_connection(:test)
load(File.dirname(__FILE__) + "/schema.rb")

class ActiveSupport::TestCase
  include ActiveRecord::TestFixtures
  self.use_transactional_fixtures = true
end
