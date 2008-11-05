require "fileutils"

module Amazon::CachingStrategy
  class Filesystem < Amazon::CachingStrategy::Base
    #disk quota in megabytes
    DEFAULT_DISK_QUOTA = 200
    
    #frequency of sweeping in hours
    DEFAULT_SWEEP_FREQUENCY = 2
    
    def self.cache(request, response)
      path = self.cache_path
      cached_filename = Digest::SHA1.hexdigest(response.request_url)
      cached_folder = cached_filename[0..2]
      
      FileUtils.mkdir_p(File.join(path, cached_folder, cached_folder))
      
      cached_file = File.open(File.join(path, cached_folder, cached_filename), "w")
      cached_file.puts response.doc.to_s
      cached_file.close
    end
    
    def self.get(request)
      path = self.cache_path
      cached_filename = Digest::SHA1.hexdigest(request)
      file_path = File.join(path, cached_filename[0..2], cached_filename)
      if FileTest.exists?(file_path)
        File.read(file_path).chomp
      else
        nil
      end
    end
    
    def self.initialize_options(options)      
      #check for required options
      if options[:caching_options].nil?
        raise Amazon::ConfigurationError, "You must specify caching options for filesystem caching: :cache_path is required"
      end
      
      @@disk_quota = options[:caching_options][:disk_quota]
      @@sweep_frequency = options[:caching_options][:sweep_frequency]
      @@cache_path = options[:caching_options][:cache_path]
      
      
      if @@cache_path.nil? || !File.directory?(@@cache_path)
        raise Amazon::ConfigurationError, "You must specify a cache path for filesystem caching"
      end
      
      return options
    end
    
    def self.sweep
      self.perform_sweep if must_sweep?
    end
    
    def self.disk_quota
      @@disk_quota || DEFAULT_DISK_QUOTA
    end
    
    def self.sweep_frequency
      @@sweep_frequency || DEFAULT_SWEEP_FREQUENCY
    end
    
    def self.cache_path
      @@cache_path
    end
    
    private
    def self.perform_sweep
      #todo: implement
      
      self.timestamp_sweep_performance
    end
    
    def self.timestamp_sweep_performance
      #remove the timestamp
      FileUtils.rm_rf(self.timestamp_filename)
      
      #create a new one its place
      timestamp = File.open(self.timestamp_filename, "w")
      timestamp.puts(Time.now)
      timestamp.close
    end
    
    def self.must_sweep?
      sweep_time_expired? || disk_quota_exceeded?
    end
    
    def self.sweep_time_expired?
      FileTest.exists?(timestamp_filename) && Time.parse(File.read(timestamp_filename).chomp) < Time.now - (sweep_frequency * 3600)
    end
    
    def self.disk_quota_exceeded?
      #todo: implement
    end
    
    def self.timestamp_filename
      File.join(self.cache_path, ".amz_timestamp")
    end
  end
  
end
