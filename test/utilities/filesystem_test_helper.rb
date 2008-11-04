module FilesystemTestHelper
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