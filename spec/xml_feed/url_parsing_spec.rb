require File.dirname(__FILE__) + "/../spec_helper"

describe XmlFeed, "parsing the url" do
  before :each do
    @url = "http://example.com/partnerfeeds/site/site.xml"
    @feed = XmlFeed.new(@url)
    @feed.stub!(:feed)
  end
  
  it "should parse the url" do
    @feed.parse_url.should == URI.parse(@url)
  end
  
  it "should have the host" do
    @feed.parse_url
    @feed.host.should == "example.com"
  end
  
  it "should have the host if the url has not yet been parsed" do
    @feed.host.should == "example.com"
  end
  
  it "should have the path" do
    @feed.parse_url
    @feed.path.should == "/partnerfeeds/site/site.xml"
  end
  
  it "should have the path if the url has not yet been parsed" do
    @feed.path.should == "/partnerfeeds/site/site.xml"
  end
end
