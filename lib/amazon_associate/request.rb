require "net/http"
require "hpricot"
require "cgi"

begin
  require 'md5'
rescue LoadError
  require 'digest/md5'
end

#--
# Copyright (c) 2009 Dan Pickett, Enlight Solutions
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++
module AmazonAssociate
  class Request
    
    SERVICE_URLS = {:us => "http://webservices.amazon.com",
        :uk => "http://webservices.amazon.co.uk",
        :ca => "http://webservices.amazon.ca",
        :de => "http://webservices.amazon.de",
        :jp => "http://webservices.amazon.co.jp",
        :fr => "http://webservices.amazon.fr"
    }
  
    # The sort types available to each product search index.
    SORT_TYPES = {
      "Apparel" => %w[relevancerank salesrank pricerank inverseprice -launch-date sale-flag],
      "Automotive" => %w[salesrank price -price titlerank -titlerank],
      "Baby" => %w[psrank salesrank price -price titlerank],
      "Beauty" => %w[pmrank salesrank price -price -launch-date sale-flag],
      "Books" => %w[relevancerank salesrank reviewrank pricerank inverse-pricerank daterank titlerank -titlerank],
      "Classical" => %w[psrank salesrank price -price titlerank -titlerank orig-rel-date],
      "DigitalMusic" => %w[songtitlerank uploaddaterank],
      "DVD" => %w[relevancerank salesrank price -price titlerank -video-release-date],
      "Electronics" => %w[pmrank salesrank reviewrank price -price titlerank],
      "GourmetFood" => %w[relevancerank salesrank pricerank inverseprice launch-date sale-flag],
      "HealthPersonalCare" => %w[pmrank salesrank pricerank inverseprice launch-date sale-flag],
      "Jewelry" => %w[pmrank salesrank pricerank inverseprice launch-date],
      "Kitchen" => %w[pmrank salesrank price -price titlerank -titlerank],
      "Magazines" => %w[subslot-salesrank reviewrank price -price daterank titlerank -titlerank],
      "Merchants" => %w[relevancerank salesrank pricerank inverseprice launch-date sale-flag],
      "Miscellaneous" => %w[pmrank salesrank price -price titlerank -titlerank],
      "Music" => %w[psrank salesrank price -price titlerank -titlerank artistrank orig-rel-date release-date],
      "MusicalInstruments" => %w[pmrank salesrank price -price -launch-date sale-flag],
      "MusicTracks" => %w[titlerank -titlerank],
      "OfficeProducts" => %w[pmrank salesrank reviewrank price -price titlerank],
      "OutdoorLiving" => %w[psrank salesrank price -price titlerank -titlerank],
      "PCHardware" => %w[psrank salesrank price -price titlerank],
      "PetSupplies" => %w[+pmrank salesrank price -price titlerank -titlerank],
      "Photo" => %w[pmrank salesrank titlerank -titlerank],
      "Restaurants" => %w[relevancerank titlerank],
      "Software" => %w[pmrank salesrank titlerank price -price],
      "SportingGoods" => %w[relevancerank salesrank pricerank inverseprice launch-date sale-flag],
      "Tools" => %w[pmrank salesrank titlerank -titlerank price -price],
      "Toys" => %w[pmrank salesrank price -price titlerank -age-min],
      "VHS" => %w[relevancerank salesrank price -price titlerank -video-release-date],
      "Video" => %w[relevancerank salesrank price -price titlerank -video-release-date],
      "VideoGames" => %w[pmrank salesrank price -price titlerank],
      "Wireless" => %w[daterank pricerank invers-pricerank reviewrank salesrank titlerank -titlerank], 
      "WirelessAccessories" => %w[psrank salesrank titlerank -titlerank]
    }
  
    # Returns an Array of valid sort types for _search_index_, or +nil+ if _search_index_ is invalid.
    def self.sort_types(search_index)
      SORT_TYPES.has_key?(search_index) ? SORT_TYPES[search_index] : nil
    end
  
    # Performs BrowseNodeLookup request, defaults to TopSellers ResponseGroup
    def self.browse_node_lookup(browse_node_id, opts = {})
      opts = self.options.merge(opts) if self.options
      opts[:operation] = "BrowseNodeLookup"
      opts[:browse_node_id] = browse_node_id
    
      self.send_request(opts)
    end
  
    # Cart operations build the Item tags from the ASIN
    # Item.ASIN.Quantity defaults to 1, unless otherwise specified in _opts_
  
    # Creates remote shopping cart containing _asin_
    def self.cart_create(items, opts = {})
      opts = self.options.merge(opts) if self.options
      opts[:operation] = "CartCreate"
      
      if items.is_a?(String)
        asin = items
        opts["Item.#{asin}.Quantity"] = opts[:quantity] || 1
        opts["Item.#{asin}.ASIN"] = asin
      else
        items.each do |item|
          (item[:offer_listing_id].nil? || item[:offer_listing_id].empty?) ? opts["Item.#{item[:asin]}.ASIN"] = item[:asin] : opts["Item.#{item[:asin]}.OfferListingId"] = item[:offer_listing_id]
          opts["Item.#{item[:asin]}.Quantity"] = item[:quantity] || 1
        end
      end
  
      self.send_request(opts)
    end
  
    # Adds items to remote shopping cart
    def self.cart_add(items, cart_id, hmac, opts = {})
      opts = self.options.merge(opts) if self.options
      opts[:operation] = "CartAdd"
      
      if items.is_a?(String)
        asin = items
        opts["Item.#{asin}.Quantity"] = opts[:quantity] || 1
        opts["Item.#{asin}.ASIN"] = asin
      else
        items.each do |item|
          (item[:offer_listing_id].nil? || item[:offer_listing_id].empty?) ? opts["Item.#{item[:asin]}.ASIN"] = item[:asin] : opts["Item.#{item[:asin]}.OfferListingId"] = item[:offer_listing_id]
          opts["Item.#{item[:asin]}.Quantity"] = item[:quantity] || 1
        end
      end
      
      opts[:cart_id] = cart_id
      opts[:hMAC] = hmac
  
      self.send_request(opts)
    end
  
    # Retrieve a remote shopping cart
    def self.cart_get(cart_id, hmac, opts = {})
      opts = self.options.merge(opts) if self.options
      opts[:operation] = "CartGet"
      opts[:cart_id] = cart_id
      opts[:hMAC] = hmac
  
      self.send_request(opts)
    end
  
    # modifies _cart_item_id_ in remote shopping cart
    # _quantity_ defaults to 0 to remove the given _cart_item_id_
    # specify _quantity_ to update cart contents
    def self.cart_modify(cart_item_id, cart_id, hmac, quantity=0, opts = {})
      opts = self.options.merge(opts) if self.options
      opts[:operation] = "CartModify"
      opts["Item.1.CartItemId"] = cart_item_id
      opts["Item.1.Quantity"] = quantity
      opts[:cart_id] = cart_id
      opts[:hMAC] = hmac
  
      self.send_request(opts)
    end
  
    # clears contents of remote shopping cart
    def self.cart_clear(cart_id, hmac, opts = {})
      opts = self.options.merge(opts) if self.options
      opts[:operation] = "CartClear"
      opts[:cart_id] = cart_id
      opts[:hMAC] = hmac
  
      self.send_request(opts)
    end
    @@options = {}
    @@debug = false

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
  
    def self.configure(&proc)
      raise ArgumentError, "Block is required." unless block_given?
      
      yield @@options
      if !@@options[:caching_strategy].nil?
        @@options.merge!(CacheFactory.initialize_options(@@options))
      end
    end
  
    # Search amazon items with search terms. Default search index option is "Books".
    # For other search type other than keywords, please specify :type => [search type param name].
    def self.item_search(terms, opts = {})
      opts[:operation] = "ItemSearch"
      opts[:search_index] = opts[:search_index] || "Books"
    
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
      opts[:operation] = "ItemLookup"
      opts[:item_id] = item_id
    
      self.send_request(opts)
    end    
        
    # Generic send request to ECS REST service. You have to specify the :operation parameter.
    def self.send_request(opts)
      opts = self.options.merge(opts) if self.options
      unsigned_url = prepare_unsigned_url(opts)
      response = nil

      if caching_enabled?
        AmazonAssociate::CacheFactory.sweep(self.options[:caching_strategy])
        
        res = AmazonAssociate::CacheFactory.get(unsigned_url, self.options[:caching_strategy]) 
        response = Response.new(res, unsigned_url) unless res.nil?
      end
      
      if !caching_enabled? || response.nil?
        request_url = prepare_signed_url(opts)
        log "Request URL: #{request_url}"
        res = Net::HTTP.get_response(URI::parse(request_url))

        unless res.kind_of? Net::HTTPSuccess
          raise AmazonAssociate::RequestError, "HTTP Response: #{res.code} #{res.message}"
        end

        response = Response.new(res.body, request_url)
        response.unsigned_url = unsigned_url

        if caching_enabled?
          cache_response(unsigned_url, response, self.options[:caching_strategy]) 
        end
      end
        
      response
    end
  
    attr_accessor :request_url, :unsigned_url

    protected
      def self.log(s)
        return unless self.debug
        if defined? RAILS_DEFAULT_LOGGER
          RAILS_DEFAULT_LOGGER.error(s)
        elsif defined? LOGGER
          LOGGER.error(s)
        else
          puts s
        end
      end
    
    private
      def self.get_service_url(opts)
        country = opts.delete(:country)
        country = (country.nil?) ? "us" : country
        url = SERVICE_URLS[country.to_sym]

        raise AmazonAssociate::RequestError, "Invalid country \"#{country}\"" unless url
        url
      end 

      def self.prepare_unsigned_url(opts)
        url = get_service_url(opts) + "/onca/xml"
      
        qs = ""
        opts.each {|k,v|
          next unless v
          next if [:caching_options, :caching_strategy, :secret_key].include?(k)
          v = v.join(",") if v.is_a? Array
          qs << "&#{camelize(k.to_s)}=#{URI.encode(v.to_s)}"
        }

        @unsigned_url = "#{url}#{qs}"
      end

      def self.prepare_signed_url(opts)
        url = get_service_url(opts) + "/onca/xml"
        
        unencoded_key_value_strings = []
        encoded_key_value_strings = []
        opts[:timestamp] = Time.now.utc.strftime("%Y-%m-%dT%H:%M:%S") + ".000Z"
        opts[:service] = "AWSECommerceService"
        opts[:version] = "2009-01-01"
        sort_parameters(opts).each do |p|
          next if p[1].nil?
          next if [:caching_options, :caching_strategy, :secret_key].include?(p[0])


          encoded_value = CGI.escape(p[1].to_s)
          
          encoded_key_value_strings << camelize(p[0].to_s ) + "=" + encoded_value
        end

        string_to_sign = 
"GET
#{get_service_url(opts).gsub("http://", "")}
/onca/xml
#{encoded_key_value_strings.join("&")}"

        signature = sign_string(string_to_sign)
        encoded_key_value_strings << "Signature=" + signature

        "#{url}?#{encoded_key_value_strings.join("&")}"
      end

      def self.sort_parameters(opts)
        key_value_strings = []
        opts.sort {|a, b| camelize(a) <=> camelize(b) }
      end

      def self.sign_string(string_to_sign)
        sha1 = HMAC::SHA256.digest(self.options[:secret_key], string_to_sign)

        #Base64 encoding adds a linefeed to the end of the string so chop the last character!
        CGI.escape(Base64.encode64(sha1).chomp)
      end
    
      def self.camelize(s)
        s.to_s.gsub(/\/(.?)/) { "::" + $1.upcase }.gsub(/(^|_)(.)/) { $2.upcase }
      end
      
      def self.caching_enabled?
        !self.options[:caching_strategy].nil?
      end
      
      def self.cache_response(request, response, options)
        AmazonAssociate::CacheFactory.cache(request, response, options)
      end
  end
end
