require File.dirname(__FILE__) + "/../spec_helper"

describe XmlFeed do
  before :each do
    @url = "http://example.com/feed.url"
    @head_hash = {"foo" => "bar"}
    @net_http = mock('Net::HTTP', :head => @head_hash)
    Net::HTTP.stub!(:start).and_yield @net_http
  end
  
  it "should get the head request" do
    feed = XmlFeed.new(@url)
    feed.head.should == @head_hash
  end
end
