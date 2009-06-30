module AmazonAssociate
  class CacheFactory
    def self.cache(request, response, strategy)
      strategy_class_hash[strategy].cache(request, response)
    end
  
    def self.initialize_options(options)
      #check for a valid caching strategy
      unless self.strategy_class_hash.keys.include?(options[:caching_strategy])
        raise AmazonAssociate::ConfigurationError, "Invalid caching strategy" 
      end

      strategy_class_hash[options[:caching_strategy]].initialize_options(options)
    end
  
    def self.get(request, strategy)
      strategy_class_hash[strategy].get(request)
    end
  
    def self.sweep(strategy)
      strategy_class_hash[strategy].sweep
    end
  
    private
    def self.strategy_class_hash
      {
        :filesystem => AmazonAssociate::CachingStrategy::Filesystem
      }
    end
  end
end