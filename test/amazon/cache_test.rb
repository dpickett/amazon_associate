require File.dirname(__FILE__) + "/../test_helper"

class Amazon::CacheTest < Test::Unit::TestCase
  @@cache_path = File.dirname(__FILE__) + "/cache/"
  context "caching setup" do
    setup do
      setup_cache_directory
      Amazon::Ecs.configure do |options|
        options[:caching_strategy] = "filesystem"
        options[:caching_options] = {:cache_path => @@cache_path}
      end
    end
    
    teardown do
      #remove cache directory
      teardown_cache_directory

      #reset caching to off
      Amazon::Ecs.configure do |options|
        options[:caching_strategy] = nil
        options[:caching_options] = nil
      end
    end
    
    should "optionally allow for a caching strategy in configuration" do
      assert_nothing_raised do
        Amazon::Ecs.configure do |options|
          options[:caching_strategy] = "filesystem"
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
    
    should "require a caching options hash with a cache_path key" do
      assert_raises(Amazon::ConfigurationError) do
        Amazon::Ecs.configure do |options|
          options[:caching_options] = nil
        end
      end
    end
    
    should "raise an exception when a cache_path is specified that doesn't exist" do
      assert_raises(Amazon::ConfigurationError) do
        Amazon::Ecs.configure do |options|
          options[:caching_options] = {:cache_path => "foo123"}
        end
      end
    end
  end
  
  private
  def setup_cache_directory
    #make the caching directory
    FileUtils.makedirs(@@cache_path)
  end
  
  def teardown_cache_directory
    #remove all the cache files
    FileUtils.rm_rf(@@cache_path)
  end
end