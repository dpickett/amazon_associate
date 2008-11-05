#abstract class
module Amazon::CachingStrategy
  class Base
    def self.cache(request, response)
      raise "This method must be overwritten by a caching strategy"
    end
    
    def self.initialize_options(options)
      raise "This method must be overwritten by a caching strategy"
    end
    
    def self.get(request)
      raise "This method must be overwritten by a caching strategy"
    end
    
    def self.sweep
      raise "This method must be overwritten by a caching strategy"
    end
  end
end