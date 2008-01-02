require File.dirname(__FILE__) + "/../spec_helper"

top_level = self

describe "XmlFeed" do
  
  before :each do
    Object.stub!(:const_defined?)
    top_level.stub!(:require)
  end
  
  def load_file
    load File.dirname(__FILE__) + "/../../lib/xml_feed.rb"
  end
  
  it "should require net/http if Net is not defined" do
    Object.stub!(:const_defined?).with(:Net).and_return false
    top_level.should_receive(:require).with("net/http")
    load_file
  end
  
  it "should require 'net/http' if Net is defined, but Net::HTTP isn't" do
    Object.stub!(:const_defined?).with(:Net).and_return true
    Net.stub!(:const_defined?).with(:HTTP).and_return false
    top_level.should_receive(:require).with("net/http")
    load_file
  end
  
  it "should not require 'net/http' if Net:HTTP is defined" do
    Object.stub!(:const_defined?).and_return true
    Net.stub!(:const_defined?).and_return true
    top_level.should_not_receive(:require).with("net/http")
    load_file
  end
  
  it "should require zlib" do
    top_level.should_receive(:require).with("zlib")
    load_file
  end
  
  it "should require xml simple if it is not defined" do
    Object.stub!(:const_defined?).and_return false
    top_level.should_receive(:require).with("xmlsimple")
    load_file
  end
  
  it "should not require xml simple if it is already defined" do
    Object.stub!(:const_defined?).and_return true
    
    top_level.should_not_receive(:require).with("xmlsimple")
    load_file
  end
end