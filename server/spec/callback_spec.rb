require File.dirname(__FILE__) + '/spec_helper'
require './lib/callback.rb'
require 'fileutils'

describe "Callback" do
  
  before :all do
    @testlog = '/tmp/callback_test.log'
  end
  
  it "posts to remote server" do
    response = {'status' => 'swipe accepted'}.to_json
    response.extend RestClient::Response
    response.stub(:code).and_return(200)
    RestClient.stub(:post).and_return(response)
    
    cb = Callback.new(:title => 'remote', 
                      :url=>'https://test.com', 
                      :passphrase => 'this is a test passphrase')
    cb.run('test').should == true    
  end

  it "fails when server incorrectly responds" do
    response = "Page not found"
    response.extend RestClient::Response
    response.stub(:code).and_return(404)
    RestClient.stub(:post).and_return(response)
        
    cb = Callback.new(:title => 'remote', 
                      :url=>'https://test.com', 
                      :passphrase => 'this is a test passphrase')
    cb.run('test').should == false
  end
  
  
    

end
