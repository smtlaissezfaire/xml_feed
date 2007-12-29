require File.dirname(__FILE__) + "/../spec_helper"

describe "An uncompressed", XmlFeed, "'s body" do
  before :each do
    @feed = XmlFeed.new("url://example.com/foo/bar")
    @xml_feed = mock('Net::HTTPOK', :body => "<xml></xml>")
  end
  
  it "should return the feed's body (even when the feed hasn't yet been gotten)" do
    @feed.stub!(:feed).and_return @xml_feed
    @feed.body.should == @xml_feed.body 
  end  
end

