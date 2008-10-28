require "rubygems"
require "test/unit"

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__) , '..', 'lib'))
require 'amazon'

Amazon::Ecs.configure do |options|
  options[:aWS_access_key_id] = ""
end

