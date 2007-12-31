require File.dirname(__FILE__) + "/../spec_helper"

describe XmlFeed, "with Last Modified On header + caching" do
  before :each do
    @feed = XmlFeed.new("http://example.com/feed.url")

    @head_parameter_hash = {
      "last-modified" => ["Wed, 26 Dec 2007 07:33:48 GMT"], 
      "etag"=>"\"2f0003-247991-7b63af00\""
    }
    @feed.stub!(:head).and_return @head_parameter_hash
    
    Net::HTTP.stub!(:start)
  end
  
  it "should have the last_modified_on as a time" do
    @feed.last_modified_on.should be_a_kind_of(Time)
  end
  
  it "should have the correct time for last_modified_on" do
    @feed.last_modified_on.should == Time.parse("Wed, 26 Dec 2007 07:33:48 GMT")
  end
  
  it "should store the last_modified_on date" do
    @feed.get_feed
    @feed.stored_last_modified_on.should == Time.parse("Wed, 26 Dec 2007 07:33:48 GMT")
  end
  
  it "should have the etag" do
    @feed.etag.should == "2f0003-247991-7b63af00"
  end
  
  it "should store the etag after getting the feed" do
    @feed.get_feed
    @feed.stored_etag.should == "2f0003-247991-7b63af00"
  end

  it "should return true to new_version? if the last modified on header timestamp is newer" do
    @feed.stub!(:last_modified_on).and_return "Wed, 27 Dec 2000 07:33:48 GMT"
    @feed.get_feed
    @feed.stub!(:last_modified_on).and_return "Wed, 27 Dec 2015 07:33:48 GMT"
    @feed.should have_new_version
  end

  it "should return true to new_version? if the etags does not match" do
    @feed.stub!(:etag).and_return "etag1"
    @feed.get_feed
    @feed.stub!(:etag).and_return "new etag - etag2"
    @feed.should have_new_version
  end
  
  it 'should return false to new_version? if the last modified header is the same, and the etags matches' do
    @feed.get_feed
    @feed.should_not have_new_version
  end
  
  it "should return true to has_new_version? if the feed was never gotten" do
    @feed.should have_new_version
  end
end

describe XmlFeed, "requesting the feed, when the feed has never been gotten before" do
  before :each do
    @feed = XmlFeed.new("url://example.com/foo/bar")
    @feed.stub!(:store_etag)
    @feed.stub!(:store_last_modified_on)
    @feed.stub!(:get_uncached_feed)
    @feed.stub!(:has_a_new_version?).and_return true
  end
  
  it "should get the feed" do
    @feed.should_receive(:get_uncached_feed)
    @feed.get_feed
  end
  
  it "should store the etag" do
    @feed.should_receive(:store_etag)
    @feed.get_feed
  end
  
  it "should store the last_modified_on date" do
    @feed.should_receive(:store_last_modified_on)
    @feed.get_feed
  end
end

describe XmlFeed, "requesting the feed, when the feed does not have a new version" do
  before :each do
    @feed = XmlFeed.new("url://example.com/foo/bar")
    @feed.stub!(:store_etag)
    @feed.stub!(:store_last_modified_on)
    @feed.stub!(:get_uncached_feed)
    
    @feed.stub!(:has_a_new_version?).and_return false
  end
  
  it "should NOT get the feed" do
    @feed.should_not_receive(:get_uncached_feed)
    @feed.get_feed
  end
  
  it "should NOT store the etag" do
    @feed.should_not_receive(:store_etag)
    @feed.get_feed
  end
  
  it "should NOT store the last_modified_on date" do
    @feed.should_not_receive(:store_last_modified_on)
    @feed.get_feed
  end
end

describe XmlFeed do
  before :each do
    @net_http_404 = mock('Net::HTTPNotFound', :[] => nil)
    @feed = XmlFeed.new("url://example.com/foo/bar")
    @feed.stub!(:head).and_return @net_http_404
  end
  
  it "should raise a parse error if the last modified on date cannot be found" do
    lambda {
      @feed.last_modified_on
    }.should raise_error(XmlFeed::FeedError, "Cannot find the Last-Modified header")
  end
  
  it "should raise a parse error if the etag cannot be found" do
    lambda {
      @feed.etag
    }.should raise_error(XmlFeed::FeedError, "Cannot find the Etag header")
  end
end

