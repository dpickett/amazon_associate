require "rubygems"
require "test/unit"
require "shoulda"

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__) , '..', 'lib'))
require 'amazon'

Amazon::Ecs.configure do |options|
  options[:aWS_access_key_id] = ""
  
  #raise exception if user has not entered their access key
  if options[:aWS_access_key_id] == ""
    raise "Access key is not entered - enter an access key in test_helper.rb if you'd like to run tests" 
  end
end
