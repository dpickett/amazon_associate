require File.dirname(__FILE__) + "/../test_helper"

class Amazon::BrowseNodeLookupTest < Test::Unit::TestCase
  
  ## Test browse_node_lookup
  def test_browse_node_lookup
    resp = Amazon::Ecs.browse_node_lookup("5")
    assert resp.is_valid_request?
    browse_node_tags = resp.doc.get_elements_by_tag_name("browsenodeid")
    browse_node_tags.each { |node| assert_equal("5", node.inner_text) }
    assert_equal "TopSellers", resp.doc.get_elements_by_tag_name("responsegroup").inner_text
  end
  
  def test_browse_node_lookup_with_browse_node_info_response
    resp = Amazon::Ecs.browse_node_lookup("5", :response_group => "BrowseNodeInfo")
    assert resp.is_valid_request?
    assert_equal "BrowseNodeInfo", resp.doc.get_elements_by_tag_name("responsegroup").inner_text
  end
  
  def test_browse_node_lookup_with_new_releases_response
    resp = Amazon::Ecs.browse_node_lookup("5", :response_group => "NewReleases")
    assert resp.is_valid_request?
    assert_equal "NewReleases", resp.doc.get_elements_by_tag_name("responsegroup").inner_text
  end
  
  def test_browse_node_lookup_with_invalid_request
    resp = Amazon::Ecs.browse_node_lookup(nil)
    assert resp.has_error?
    assert resp.error
  end

  def test_browse_node_lookup_with_no_result
    resp = Amazon::Ecs.browse_node_lookup("abc")
    
    assert resp.is_valid_request?
    assert_match(/abc is not a valid value for BrowseNodeId/, resp.error)
  end
end
