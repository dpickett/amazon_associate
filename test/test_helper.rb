require "rubygems"
require "test/unit"
require "shoulda"
require "mocha"

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__) , '..', 'lib'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__) , 'utilities'))
require "filesystem_test_helper"
require 'amazon_associate'


AmazonAssociate::Request.configure do |options|
  options[:aWS_access_key_id] = ENV["AWS_ACCESS_KEY"] || ""
  options[:secret_key] = ENV["AWS_SECRET_KEY"] || ""
  
  #raise exception if user has not entered their access key
  if options[:aWS_access_key_id] == ""
    raise "Access key is not entered - enter an access key in test_helper.rb if you'd like to run tests" 
  end
end
