require File.dirname(__FILE__) + "/spec_helper"

describe XmlFeed do
  it "should assume that the feed is uncompressed, by default" do
    XmlFeed.new("feed_url").should_not be_compressed
  end
  
  it "should not be compressed, if specified" do
    feed = XmlFeed.new("feed_url", false)
    feed.should_not be_compressed
  end
  
  it "should be compressed, if specified" do
    feed = XmlFeed.new("feed_url", true)
    feed.should be_compressed
  end
  
  it "should initialize with a feed url" do
    feed = XmlFeed.new("url")
    feed.feed_url.should == "url"
  end  
end

describe XmlFeed do
  before :each do
    @feed_hash = {
      :writing => "url1",
      :editing => "url2"
    }
    
    @mock_response = mock(Net::HTTP)
    Net::HTTP.stub!(:start).and_yield @mock_response  
    @mock_response.stub!(:head).and_return [{"etag" => "foobar", "last-modified" => "Dec 2007"}]
    Zlib::Inflate.stub!(:inflate)
  end
  
  it "should be able to get the uncached feed" do
    feed = XmlFeed.new("http://www.google.com/foobar")
    feed_body = "<xml><feed-body>hello, world!</feed-body></xml>"
    @mock_response.stub!(:get).and_return feed_body

    @mock_response.should_receive(:get).with("/foobar").and_return feed_body
    feed.get_uncached_feed
  end

  it "should raise a FeedError if the site can not be reached" do
    Net::HTTP.stub!(:start).and_raise(StandardError)
    feed = XmlFeed.new("foo_bar")
    feed.stub!(:host)
    feed.stub!(:path)
    
    lambda {
      feed.get_uncached_feed
    }.should raise_error(XmlFeed::FeedError, "Error with feed: StandardError")
  end
  
  it "should return the feed as an xml simple object" do
    @xml_simple = mock(XmlSimple)
    XmlSimple.stub!(:xml_in).and_return @xml_simple

    xml = "<xml></xml>"
    feed = XmlFeed.new("foo bar")
    feed.stub!(:body).and_return xml
    
    XmlSimple.should_receive(:xml_in).with(xml).and_return @xml_simple
    feed.to_xml_simple    
  end
end  

describe XMLFeed do
  it "should be the same as the XmlFeed" do
    XMLFeed.should == XmlFeed
  end
end