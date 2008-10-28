require File.dirname(__FILE__) + "/../test_helper"

require "ruby-debug"
class Amazon::CartTest < Test::Unit::TestCase
  
  # create a cart to store cart_id and hmac for add, get, modify, and clear tests
  def setup
    @asin = "0672328844"
    resp = Amazon::Ecs.cart_create(@asin)
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
    resp = Amazon::Ecs.cart_get(@cart_id, @hmac)
    assert resp.is_valid_request?
    assert_not_nil resp.doc.get_elements_by_tag_name("purchaseurl").inner_text
  end
  
  # Test cart_modify
  def test_cart_modify
    resp = Amazon::Ecs.cart_get(@cart_id, @hmac)
    cart_item_id = resp.doc.get_elements_by_tag_name("cartitemid").inner_text
    resp = Amazon::Ecs.cart_modify(cart_item_id, @asin, @cart_id, @hmac, 2)
    item = resp.first_item
    debugger
    assert resp.is_valid_request?
    assert_equal "2", item.get("quantity")
    assert_not_nil resp.doc.get_elements_by_tag_name("purchaseurl").inner_text
  end
  
  # Test cart_clear
  def test_cart_clear
    resp = Amazon::Ecs.cart_clear(@cart_id, @hmac)
    assert resp.is_valid_request?
  end
  
  ## Test cart_create with a specified quantity
  ## note this will create a separate cart
  def test_cart_create_with_quantity
    asin = "0672328844"
    resp = Amazon::Ecs.cart_create(asin, :quantity => 2)
    assert resp.is_valid_request?
    item = resp.first_item
    assert_equal asin, item.get("asin")
    assert_equal "2", item.get("quantity")
    assert_not_nil resp.doc.get_elements_by_tag_name("cartid").inner_text
    assert_not_nil resp.doc.get_elements_by_tag_name("hmac").inner_text
  end
  
end