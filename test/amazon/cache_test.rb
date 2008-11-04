require File.dirname(__FILE__) + "/../test_helper"

class Amazon::CacheTest < Test::Unit::TestCase
  include FilesystemTestHelper
  context "caching get" do
    setup do
      get_cache_directory
      get_valid_caching_options
    end
    
    teardown do
      destroy_cache_directory
      destroy_caching_options
    end
    
    should "optionally allow for a caching strategy in configuration" do
      assert_nothing_raised do
        Amazon::Ecs.configure do |options|
          options[:caching_strategy] = :filesystem
        end
      end
    end
    
    should "raise an exception if a caching strategy is specified that is not found" do
      assert_raises(Amazon::ConfigurationError) do
        Amazon::Ecs.configure do |options|
          options[:caching_strategy] = "foo"
        end
      end
    end
    
    
  end
end