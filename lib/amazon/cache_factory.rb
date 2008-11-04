class Amazon::CacheFactory
  def self.cache(request, response, options)
    strategy_class_hash[options[:caching_strategy]].cache(request, response, options)
  end
  
  def self.validate(options)
    #check for a valid caching strategy
    unless self.strategy_class_hash.keys.include?(options[:caching_strategy])
      raise Amazon::ConfigurationError, "Invalid caching strategy" 
    end
    strategy_class_hash[options[:caching_strategy]].validate(options)
  end
  
  def self.get(request, options)
    strategy_class_hash[options[:caching_strategy]].get(request, options)
  end
  
  private
  def self.strategy_class_hash
    {
      :filesystem => Amazon::CachingStrategy::Filesystem
    }
  end
end