require File.dirname(__FILE__) + "/../spec_helper"

describe XmlFeed, "feed" do
  before :each do
    @feed = XmlFeed.new("url://example.com/foo/bar")
    @xml_feed = mock('Net::HTTPOK', :body => "<xml></xml>")
    @feed.stub!(:get_feed).and_return "feed"
  end
  
  it "should find the feed if it hasn't previously been gotten" do
    @feed.should_receive(:get_feed).and_return "feed"
    @feed.feed
  end  
end