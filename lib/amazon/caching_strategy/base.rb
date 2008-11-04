module Amazon::CachingStrategy
  class Base
    def self.cache(request, response, options)
      raise "This method must be overwritten by a caching strategy"
    end
    
    def self.validate(options)
      raise "This method must be overwritten by a caching strategy"
    end
  end
end