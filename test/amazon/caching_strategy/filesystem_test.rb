require File.dirname(__FILE__) + "/../../test_helper"

class Amazon::CachingStrategy::FilesystemTest < Test::Unit::TestCase
  
  context "setting up filesystem caching" do
    teardown do
      Amazon::Ecs.configure do |options|
        options[:caching_strategy] = nil
        options[:caching_options] = nil
      end
    end
    
    should "require a caching options hash with a cache_path key" do
      assert_raises(Amazon::ConfigurationError) do
        Amazon::Ecs.configure do |options|
          options[:caching_strategy] = :filesystem
          options[:caching_options] = nil
        end
      end
    end
    
    should "raise an exception when a cache_path is specified that doesn't exist" do
      assert_raises(Amazon::ConfigurationError) do
        Amazon::Ecs.configure do |options|
          options[:caching_strategy] = :filesystem
          options[:caching_options] = {:cache_path => "foo123"}
        end
      end
    end
  end
  
  context "caching a request" do
    
    setup do
      get_cache_directory
      get_valid_caching_options
      @resp = Amazon::Ecs.item_lookup("0974514055")
      @filename = Digest::SHA1.hexdigest(@resp.request_url)
    end
    
    teardown do
      destroy_cache_directory
      destroy_caching_options
    end
    
    should "create a file in the cache path with a digested version of the url " do
      
      filename = Digest::SHA1.hexdigest(@resp.request_url)
      assert FileTest.exists?(@@cache_path + @filename)
    end
    
    should "create a file in the cache path with the response inside it" do
      assert FileTest.exists?(@@cache_path + @filename)
      assert_equal @resp.doc.to_s, File.read(@@cache_path + @filename).chomp
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
