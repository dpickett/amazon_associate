require "rubygems"
require "test/unit"

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__) , '..', 'lib'))
require 'amazon'

Amazon::Ecs.configure do |options|
  # I had to remove the options[:response_group] setting because
  # "Large" isn"t a valid response group for browse_node_lookups
  options[:aWS_access_key_id] = "05S9H7883ANCJCTF15G2"
end

