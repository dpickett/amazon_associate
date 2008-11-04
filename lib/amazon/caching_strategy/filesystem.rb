module Amazon::CachingStrategy
  class Filesystem < Amazon::CachingStrategy::Base
    def self.cache(request, response, options)
      path = options[:caching_options][:cache_path]
      cached_filename = Digest::SHA1.hexdigest(response.request_url)
      
      cached_file = File.open(File.join(path, cached_filename), "w")
      cached_file.puts response.doc.to_s
      cached_file.close
    end
    
    def self.validate(options)
      #check for required options
      if options[:caching_options].nil?
        raise Amazon::ConfigurationError, "You must specify caching options for filesystem caching: :cache_path is required"
      end
      
      if options[:caching_options][:cache_path].nil? || !File.directory?(options[:caching_options][:cache_path])
        raise Amazon::ConfigurationError, "You must specify a cache path for filesystem caching"
      end
    end
  end
end
