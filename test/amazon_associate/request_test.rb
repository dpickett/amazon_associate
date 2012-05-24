require File.dirname(__FILE__) + "/../test_helper"

class AmazonAssociate::RequestTest < Test::Unit::TestCase
  def setup
    sleep(1)
    AmazonAssociate::Request.configure do |options|
      options[:response_group] = "Large"
    end
  end

  ## Test item_search
  def test_item_search
    resp = AmazonAssociate::Request.item_search("ruby")
    assert(resp.is_valid_request?)
    assert(resp.total_results >= 3600)
    assert(resp.total_pages >= 360)
  end

  def test_item_search_with_paging
    resp = AmazonAssociate::Request.item_search("ruby", :item_page => 2)
    assert resp.is_valid_request?
    assert 2, resp.item_page
  end

  def test_item_search_with_invalid_request
    resp = AmazonAssociate::Request.item_search(nil)
    assert !resp.is_valid_request?
  end

  def test_item_search_with_no_result
    resp = AmazonAssociate::Request.item_search("afdsafds")

    assert resp.is_valid_request?
    assert_equal "We did not find any matches for your request.",
      resp.error
  end

  def test_item_search_uk
    resp = AmazonAssociate::Request.item_search("ruby", :country => :uk)
    assert resp.is_valid_request?
  end

  def test_item_search_by_author
    resp = AmazonAssociate::Request.item_search("dave", :type => :author)
    assert resp.is_valid_request?
  end

  def test_item_get
    resp = AmazonAssociate::Request.item_search("0974514055")
    item = resp.first_item

    # test get
    assert_equal "Programming Ruby: The Pragmatic Programmers' Guide, Second Edition",
      item.get("itemattributes/title")

    # test get_array
    assert_equal ["Dave Thomas", "Chad Fowler", "Andy Hunt"],
      item.get_array("author")

    # test get_hash
    small_image = item.get_hash("smallimage")

    assert_equal 3, small_image.keys.size
    assert small_image[:url] != nil
    assert_equal "75", small_image[:height]
    assert_equal "59", small_image[:width]

    # test /
    reviews = item/"editorialreview"
    reviews.each do |review|
      # returns unescaped HTML content, Hpricot escapes all text values
      assert AmazonAssociate::Element.get_unescaped(review, "source")
      assert AmazonAssociate::Element.get_unescaped(review, "content")
    end
  end

  ## Test item_lookup
  def test_item_lookup
    resp = AmazonAssociate::Request.item_lookup("0974514055")
    assert_equal "Programming Ruby: The Pragmatic Programmers' Guide, Second Edition",
    resp.first_item.get("itemattributes/title")
  end

  def test_item_lookup_with_invalid_request
    resp = AmazonAssociate::Request.item_lookup(nil)
    assert resp.has_error?
    assert resp.error
  end

  def test_item_lookup_with_no_result
    resp = AmazonAssociate::Request.item_lookup("abc")

    assert resp.is_valid_request?
    assert_match(/ABC is not a valid value for ItemId/, resp.error)
  end

  def test_search_and_convert
    resp = AmazonAssociate::Request.item_lookup("0974514055")
    title = resp.first_item.get("itemattributes/title")
    authors = resp.first_item.search_and_convert("author")

    assert_equal "Programming Ruby: The Pragmatic Programmers' Guide, Second Edition", title
    assert authors.is_a?(Array)
    assert 3, authors.size
    assert_equal "Dave Thomas", authors.first.get
  end

end
