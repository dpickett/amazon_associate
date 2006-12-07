require 'net/http'
require 'hpricot'
require 'cgi'

module Amazon
  class RequestError < StandardError; end
  
  # :include: README 
  class Ecs
    SERVICE_URLS = {:us => 'http://webservices.amazon.com/onca/xml?Service=AWSECommerceService',
        :uk => 'http://webservices.amazon.co.uk/onca/xml?Service=AWSECommerceService',
        :ca => 'http://webservices.amazon.ca/onca/xml?Service=AWSECommerceService',
        :de => 'http://webservices.amazon.de/onca/xml?Service=AWSECommerceService',
        :jp => 'http://webservices.amazon.de/onca/xml?Service=AWSECommerceService',
        :fr => 'http://webservices.amazon.co.jp/onca/xml?Service=AWSECommerceService'
    }
    
    @@debug, @@options = nil

    # Default search options
    def self.options
      @@options
    end
    
    # Set default search options
    def self.options=(opts)
      @@options = opts
    end
    
    # Get debug flag.
    def self.debug
      @@debug
    end
    
    # Set debug flag to true or false.
    def self.debug=(dbg)
      @@debug = dbg
    end    
    
    # Search amazon items with search terms. Default search index option is 'Books'.
    # For other search type other than keywords, please specify :type => [search type param name].
    def self.item_search(terms, opts = {})
      opts = self.options.merge(opts) if self.options
      opts[:operation] = 'ItemSearch'
      opts[:search_index] = opts[:search_index] || 'Books'
      
      type = opts.delete(:type)
      if type 
        opts[type.to_sym] = terms
      else 
        opts[:keywords] = terms
      end
      
      self.send_request(opts)
    end

    # Search an item by ASIN no.
    def self.item_lookup(item_id, opts = {})
      opts = self.options.merge(opts) if self.options
      opts[:operation] = 'ItemLookup'
      opts[:item_id] = item_id
      
      # not allowed in item_lookup
      opts.delete(:search_index)
      
      self.send_request(opts)
    end
    
    # Generic send request to ECS REST service. You have to specify the :operation parameter.
    def self.send_request(opts)
      request_url = prepare_url(opts)
      log "Request URL: #{request_url}"
      
      res = Net::HTTP.get_response(URI::parse(request_url))
      unless res.kind_of? Net::HTTPSuccess
        raise Amazon::RequestError, "HTTP Response: #{res.code} #{res.message}"
      end
      Response.new(res.body)
    end

    # Response object returned after a REST call to Amazon service.
    class Response
      # XML input is in string format
      def initialize(xml)
        @doc = Hpricot(xml)
      end

      # Return Hpricot object.
      def doc
        @doc
      end

      # Return true if request is valid.
      def is_valid_request?
        (@doc/"isvalid").inner_html == "True"
      end

      # Return true if response has an error.
      def has_error?
        !(error.nil? || error.empty?)
      end

      # Return error message.
      def error
        Element.get(@doc, "error/message")
      end
      
      # Return an array of Amazon::Element item objects.
      def items
        unless @items
          @items = (@doc/"item").collect {|item| Element.new(item)}
        end
        @items
      end
      
      # Return the first item (Amazon::Element)
      def first_item
        items.first
      end
      
      # Return current page no if :item_page option is when initiating the request.
      def item_page
        unless @item_page
          @item_page = (@doc/"itemsearchrequest/itempage").inner_html.to_i
        end
        @item_page
      end

      # Return total results.
      def total_results
        unless @total_results
          @total_results = (@doc/"totalresults").inner_html.to_i
        end
        @total_results
      end
      
      # Return total pages.
      def total_pages
        unless @total_pages
          @total_pages = (@doc/"totalpages").inner_html.to_i
        end
        @total_pages
      end
    end
    
    protected
      def self.log(s)
        return unless self.debug
        if RAILS_DEFAULT_LOGGER
          RAILS_DEFAULT_LOGGER.error(s)
        else
          puts s
        end
      end
      
    private 
      def self.prepare_url(opts)
        country = opts.delete(:country)
        country = (country.nil?) ? 'us' : country
        request_url = SERVICE_URLS[country.to_sym]
        raise Amazon::RequestError, "Invalid country '#{country}'" unless request_url
        
        qs = ''
        opts.each {|k,v|
          next unless v
          v = v.join(',') if v.is_a? Array
          qs << "&#{camelize(k.to_s)}=#{URI.encode(v.to_s)}"
        }
        "#{request_url}#{qs}"
      end
      
      def self.camelize(s)
        s.to_s.gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
      end
  end

  # Internal wrapper class to provide convenient method to access Hpricot element value.
  class Element
    # Pass Hpricot::Elements object
    def initialize(element)
      @element = element
    end

    # Returns Hpricot::Elments object    
    def elem
      @element
    end
    
    # Find Hpricot::Elements matching the given path. Example: element/"author".
    def /(path)
      elements = @element/path
      return nil if elements.size == 0
      elements
    end

    # Get the text value of the given path, leave empty to retrieve current element value.
    def get(path='')
      Element.get(@element, path)
    end
    
    # Get the unescaped HTML text of the given path.
    def get_unescaped(path='')
      Element.get_unescaped(@element, path)
    end
    
    # Get the array values of the given path.
    def get_array(path='')
      Element.get_array(@element, path)
    end

    # Get the children element text values in hash format with the element names as the hash keys.
    def get_hash(path='')
      Element.get_hash(@element, path)
    end

    # Similar to #get, except an element object must be passed-in.
    def self.get(element, path='')
      return unless element
      result = element.at(path)
      result = result.inner_html if result
      result
    end
    
    # Similar to #get_unescaped, except an element object must be passed-in.    
    def self.get_unescaped(element, path='')
      CGI::unescapeHTML(get(element, path))
    end

    # Similar to #get_array, except an element object must be passed-in.
    def self.get_array(element, path='')
      return unless element
      
      result = element/path
      if (result.is_a? Hpricot::Elements) || (result.is_a? Array)
        parsed_result = []
        result.each {|item|
          parsed_result << Element.get(item)
        }
        parsed_result
      else
        [Element.get(result)]
      end
    end

    # Similar to #get_hash, except an element object must be passed-in.
    def self.get_hash(element, path='')
      return unless element
    
      result = element.at(path)
      if result
        hash = {}
        result = result.children
        result.each do |item|
          hash[item.name.to_sym] = item.inner_html
        end 
        hash
      end
    end
    
    def to_s
      elem.to_s if elem
    end
  end
end