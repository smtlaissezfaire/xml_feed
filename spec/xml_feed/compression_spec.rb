require File.dirname(__FILE__) + "/../spec_helper"

describe "A compressed", XmlFeed, "'s body" do
  before :each do
    @compressed_body = "compressed xml"
    @uncompressed_body = "<xml></xml>"
    
    @feed = XmlFeed.new("url://example.com/foo/bar.gz", true)
    @xml_feed = mock('Net::HTTPOK', :body => @compressed_body)
    Net::HTTP.stub!(:start).and_return @xml_feed
    @feed.stub!(:has_a_new_version?).and_return true
    @feed.stub!(:store_etag_and_last_modified_on)
    
    Zlib::GzipReader.stub!(:inflate).and_return @uncompressed_body
  end
  
  it "should return the feed's body, uncompressed (even when the feed has not yet been retrieved)" do
    @feed.body.should == @uncompressed_body
  end
  
  it "should uncompress the feed on demand (when asking for the body)" do
    Zlib::GzipReader.should_receive(:inflate).with(@compressed_body).and_return @uncompressed_body
    @feed.body
  end
  
  it "should be compressed if the feed has not yet been uncompressed" do
    @feed.should be_compressed
  end
  
  it "should not be compressed if the uncompression has already run" do
    @feed.body
    @feed.should_not be_compressed
  end
end
