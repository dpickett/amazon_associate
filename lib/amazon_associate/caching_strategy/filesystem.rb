require "fileutils"
require "find"

module AmazonAssociate
  module CachingStrategy
    class Filesystem < AmazonAssociate::CachingStrategy::Base
      #disk quota in megabytes
      DEFAULT_DISK_QUOTA = 200
    
      #frequency of sweeping in hours
      DEFAULT_SWEEP_FREQUENCY = 2
      
      class << self
        attr_accessor :cache_path
        attr_accessor :disk_quota
        attr_accessor :sweep_frequency

        def cache(request, response)
          path = self.cache_path
          cached_filename = Digest::SHA1.hexdigest(response.request_url)
          cached_folder = cached_filename[0..2]
        
          FileUtils.mkdir_p(File.join(path, cached_folder, cached_folder))
        
          cached_file = File.open(File.join(path, cached_folder, cached_filename), "w")
          cached_file.puts response.doc.to_s
          cached_file.close
        end
      
        def get(request)
          path = self.cache_path
          cached_filename = Digest::SHA1.hexdigest(request)
          file_path = File.join(path, cached_filename[0..2], cached_filename)
          if FileTest.exists?(file_path)
            File.read(file_path).chomp
          else
            nil
          end
        end
      
        def initialize_options(options)      
          #check for required options
          if options[:caching_options].nil? || options[:caching_options][:cache_path].nil?
            raise AmazonAssociate::ConfigurationError, "You must specify caching options for filesystem caching: :cache_path is required"
          end

          #default disk quota to 200MB
          Filesystem.disk_quota = options[:caching_options][:disk_quota] || DEFAULT_DISK_QUOTA
        
          Filesystem.sweep_frequency = options[:caching_options][:sweep_frequency] || DEFAULT_SWEEP_FREQUENCY
        
          Filesystem.cache_path = options[:caching_options][:cache_path]
        
          if Filesystem.cache_path.nil? || !File.directory?(Filesystem.cache_path)
            raise AmazonAssociate::ConfigurationError, "You must specify a cache path for filesystem caching"
          end
          return options
        end
      
        def sweep
          perform_sweep if must_sweep?
        end
      
        private
        def perform_sweep
          FileUtils.rm_rf(Dir.glob("#{Filesystem.cache_path}/*"))
        
          timestamp_sweep_performance
        end
      
        def timestamp_sweep_performance
          #remove the timestamp
          FileUtils.rm_rf(timestamp_filename)
        
          #create a new one its place
          timestamp = File.open(timestamp_filename, "w")
          timestamp.puts(Time.now)
          timestamp.close
        end
      
        def must_sweep?
          sweep_time_expired? || disk_quota_exceeded?
        end
      
        def sweep_time_expired?
          FileTest.exists?(timestamp_filename) && Time.parse(File.read(timestamp_filename).chomp) < Time.now - (sweep_frequency * 3600)
        end
      
        def disk_quota_exceeded?
          cache_size > Filesystem.disk_quota
        end
      
        def timestamp_filename
          File.join(Filesystem.cache_path, ".amz_timestamp")
        end
      
        def cache_size
          size = 0
          Find.find(Filesystem.cache_path) do|f|
             size += File.size(f) if File.file?(f)
          end
          size / 1000000
        end

      end

    end
  end
end
