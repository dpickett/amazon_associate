# Internal wrapper class to provide convenient method to access Hpricot element value.
module AmazonAssociate
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

    # Find Hpricot::Elements matching the given path, and convert to AmazonAssociate::Element.
    # Returns an array AmazonAssociate::Elements if more than Hpricot::Elements size is greater than 1.
    def search_and_convert(path)
      elements = self./(path)
      return unless elements
      elements = elements.map{|element| Element.new(element)}
      return elements.first if elements.size == 1
      elements
    end

    # Get the text value of the given path, leave empty to retrieve current element value.
    def get(path="")
      Element.get(@element, path)
    end

    # Get the unescaped HTML text of the given path.
    def get_unescaped(path="")
      Element.get_unescaped(@element, path)
    end

    # Get the array values of the given path.
    def get_array(path="")
      Element.get_array(@element, path)
    end

    # Get the children element text values in hash format with the element names as the hash keys.
    def get_hash(path="")
      Element.get_hash(@element, path)
    end

    # Similar to #get, except an element object must be passed-in.
    def self.get(element, path="")
      return unless element
      result = element.at(path)
      result = result.inner_html if result
      result
    end

    # Similar to #get_unescaped, except an element object must be passed-in.
    def self.get_unescaped(element, path="")
      result = get(element, path)
      CGI::unescapeHTML(result) if result
    end

    # Similar to #get_array, except an element object must be passed-in.
    def self.get_array(element, path="")
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
    def self.get_hash(element, path="")
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
