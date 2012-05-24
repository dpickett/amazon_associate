require File.dirname(__FILE__) + "/../test_helper"

class AmazonAssociate::CartTest < Test::Unit::TestCase

  # create a cart to store cart_id and hmac for add, get, modify, and clear tests
  def setup
    sleep(2)
    @asin = "0672328844"
    resp = AmazonAssociate::Request.cart_create(@asin)
    @cart_id = resp.doc.get_elements_by_tag_name("cartid").inner_text
    @hmac = resp.doc.get_elements_by_tag_name("hmac").inner_text
    item = resp.first_item
    # run tests for cart_create with default quantity while we"re at it
    assert resp.is_valid_request?
    assert_equal @asin, item.get("asin")
    assert_equal "1", item.get("quantity")
    assert_not_nil @cart_id
    assert_not_nil @hmac
  end

  # Test cart_get
  def test_cart_get
    resp = AmazonAssociate::Request.cart_get(@cart_id, @hmac)
    assert resp.is_valid_request?
    assert_not_nil resp.doc.get_elements_by_tag_name("purchaseurl").inner_text
  end

  # Test cart_modify
  def test_cart_modify
    resp = AmazonAssociate::Request.cart_get(@cart_id, @hmac)
    cart_item_id = resp.doc.get_elements_by_tag_name("cartitemid").inner_text
    resp = AmazonAssociate::Request.cart_modify(cart_item_id, @cart_id, @hmac, 2)
    item = resp.first_item

    assert resp.is_valid_request?
    assert_equal "2", item.get("quantity")
    assert_not_nil resp.doc.get_elements_by_tag_name("purchaseurl").inner_text
  end

  # Test cart_clear
  def test_cart_clear
    resp = AmazonAssociate::Request.cart_clear(@cart_id, @hmac)
    assert resp.is_valid_request?
  end

  ## Test cart_create with a specified quantity
  ## note this will create a separate cart
  def test_cart_create_with_quantity
    asin = "0672328844"
    resp = AmazonAssociate::Request.cart_create(asin, :quantity => 2)
    assert resp.is_valid_request?
    item = resp.first_item
    assert_equal asin, item.get("asin")
    assert_equal "2", item.get("quantity")
    assert_not_nil resp.doc.get_elements_by_tag_name("cartid").inner_text
    assert_not_nil resp.doc.get_elements_by_tag_name("hmac").inner_text
  end

  # Test cart_create with an array of hashes representing multiple items
  def test_cart_create_with_multiple_items
    items = [ { :asin => "0974514055", :quantity => 2 }, { :asin => "0672328844", :quantity => 3 } ]
    resp = AmazonAssociate::Request.cart_create(items)
    assert resp.is_valid_request?
    first_item, second_item = resp.items.reverse[0], resp.items.reverse[1]

    assert_equal items[0][:asin], first_item.get("asin")
    assert_equal items[0][:quantity].to_s, first_item.get("quantity")

    assert_equal items[1][:asin], second_item.get("asin")
    assert_equal items[1][:quantity].to_s, second_item.get("quantity")

    assert_not_nil resp.doc.get_elements_by_tag_name("cartid").inner_text
    assert_not_nil resp.doc.get_elements_by_tag_name("hmac").inner_text
  end

  # Test cart_create with offer_listing_id instead of asin
  def test_cart_create_with_offer_listing_id
    items = [ { :offer_listing_id => "MCK%2FnCXIges8tpX%2B222nOYEqeZ4AzbrFyiHuP6pFf45N3vZHTm8hFTytRF%2FLRONNkVmt182%2BmeX72n%2BbtUcGEtpLN92Oy9Y7", :quantity => 2 } ]
    resp = AmazonAssociate::Request.cart_create(items)
    assert resp.is_valid_request?
    first_item = resp.items.first

    assert_equal items[0][:offer_listing_id], first_item.get("offerlistingid")
    assert_equal items[0][:quantity].to_s, first_item.get("quantity")

    assert_not_nil resp.doc.get_elements_by_tag_name("cartid").inner_text
    assert_not_nil resp.doc.get_elements_by_tag_name("hmac").inner_text
  end

end
