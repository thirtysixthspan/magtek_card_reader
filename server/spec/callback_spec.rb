require File.dirname(__FILE__) + '/spec_helper'
require './lib/callback.rb'
require 'fileutils'

describe "Callback" do
  
  before :all do
    @testlog = '/tmp/callback_test.log'
  end
  
  it "writes to file" do
    FileUtils.rm @testlog if File.exists?(@testlog)
    cb = Callback.new(:url=>'/tmp/callback_test.log')
    cb.run(:timestamp => Time.now.to_i, :data => 'test')
    
    File.exists?(@testlog).should == true
  end

  it "fails when server incorrectly responds" do
    response = "Page not found"
    response.extend RestClient::Response
    response.stub(:code).and_return(404)
    RestClient.stub(:post).and_return(response)
        
    cb = Callback.new(:url=>'https://test.com')
    expect {
      cb.run(:timestamp => Time.now.to_i, :data => 'test')
    }.to raise_error(Exception)
  end
  
  
  it "posts to remote server" do
    response = "accepted"
    response.extend RestClient::Response
    response.stub(:code).and_return(200)
    RestClient.stub(:post).and_return(response)
    
    cb = Callback.new(:url=>'https://test.com')
    cb.run(:timestamp => Time.now.to_i, :data => 'test')
    
  end
    

end
