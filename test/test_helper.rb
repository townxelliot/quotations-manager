ENV["RAILS_ENV"] = "test"

# Expand the path to environment so that Ruby does not load it multiple times
# File.expand_path can be removed if Ruby 1.9 is in use.
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'application'

require 'test/unit'
require 'active_record/fixtures'
require 'action_controller/test_process'
require 'action_web_service/test_invoke'
require 'breakpoint'
require 'pp'

Test::Unit::TestCase.fixture_path = File.dirname(__FILE__) + "/fixtures/"

class Test::Unit::TestCase
  # Turn these on to use transactional fixtures with table_name(:fixture_name) instantiation of fixtures
  # self.use_transactional_fixtures = true
  # self.use_instantiated_fixtures  = false

  def create_fixtures(*table_names)
    Fixtures.create_fixtures(File.dirname(__FILE__) + "/fixtures", table_names)
  end

  # can object be destroyed successfully?
  def assert_destroyable(obj)
    klass = obj.class
    id = obj.id
    obj.destroy
    assert_raise(ActiveRecord::RecordNotFound) { klass.find(id) }
  end
  
  # is whitespace stripped off the start and end of a string?
  def assert_trimmed(obj, attr)
    val_orig = eval("obj.%s" % attr)
    val_new = " %s " % val_orig
    eval("obj.%s = val_new" % attr)
    obj.save
    obj.reload
    assert_equal val_orig, eval("obj.%s" % attr)
  end
  
  # return true if field does not accept whitespace only
  def assert_reject_whitespace(obj, attr)
    eval("obj.%s = '    '" % attr)
    assert !obj.save
  end
  
  # return true if empty attr field causes save to fail (desired result)
  def assert_reject_empty(obj, attr)
    eval("obj.%s = nil" % attr)
    assert !obj.save
  end
end