require File.dirname(__FILE__) + "/../test_helper"

class Amazon::CacheTest < Test::Unit::TestCase
  
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
  
  @@cache_path = File.dirname(__FILE__) + "/cache/"

  protected
  def get_valid_caching_options
    #configure Amazon library for filesystem caching
    Amazon::Ecs.configure do |options|
      options[:caching_strategy] = :filesystem
      options[:caching_options] = {:cache_path => @@cache_path}
    end
  end

  def destroy_caching_options
    #reset caching to off
    Amazon::Ecs.configure do |options|
      options[:caching_strategy] = nil
      options[:caching_options] = nil
    end
  end

  def get_cache_directory
    #make the caching directory
    FileUtils.makedirs(@@cache_path)
  end

  def destroy_cache_directory
    #remove all the cache files
    FileUtils.rm_rf(@@cache_path)
  end
end