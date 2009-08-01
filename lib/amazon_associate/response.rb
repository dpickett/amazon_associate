module AmazonAssociate
  # Response object returned after a REST call to Amazon service.
  class Response
    
    attr_accessor :request_url, :unsigned_url
    # XML input is in string format
    def initialize(xml, request_url)
      @doc = Hpricot(xml)
      @items = nil
      @item_page = nil
      @total_results = nil
      @total_pages = nil
    
      self.request_url = request_url
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

    # Return an array of AmazonAssociate::Element item objects.
    def items
      unless @items
        @items = (@doc/"item").collect {|item| Element.new(item)}
      end
      @items
    end

    # Return the first item (AmazonAssociate::Element)
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
end
