
require 'rubygems'
require 'net/http'  unless Object.const_defined?(:Net) && Net.const_defined?(:HTTP)
require 'zlib'      
require 'xmlsimple' unless Object.const_defined?(:XmlSimple)
require 'time'      

class XmlFeed

  class FeedError < StandardError; end

  def initialize(feed_url, compressed=false)
    @feed_url = feed_url
    @compressed = compressed
  end
  
  attr_reader :feed_url, :stored_etag, :stored_last_modified_on
  
  def parse_url
    @parsed_url ||= URI.parse(feed_url)
  end
  
  def parsed_url
    parse_url
  end
  
  def host
    parsed_url.host
  end
  
  def path
    parsed_url.path
  end
  
  def feed
    get_feed unless @feed
    @feed
  end
  
  # TODO: should return the uncompressed body,
  # even when get_uncached_feed hasn't yet been called
  def body
    if compressed?
      get_feed
      uncompress_feed
    end
    
    @uncompressed_body || feed.body
  end
  
  def compressed?
    @compressed
  end
  
  def to_xml_simple
    XmlSimple.xml_in(self.body)
  end
  
  def head
    head = nil
    http_session { |http| head = http.head(path) }
    return head
  end
  
  def last_modified_on
    begin
      Time.parse head["last-modified"].first
    rescue
      raise FeedError, "Cannot find the Last-Modified header"
    end
  end
  
  def etag
    begin
      head["etag"].gsub("\"", "")
    rescue
      raise FeedError, "Cannot find the Etag header"
    end
  end
  
  # This method is lazy - it will get the feed the first time,
  # but not on subsequent runs (unless it has_a_new_version?)
  def get_feed
    if has_a_new_version?
      store_etag_and_last_modified_on
      get_uncached_feed
    end
  end
  
  def has_new_version?
    @stored_last_modified_on == last_modified_on && @stored_etag == etag ? false : true
  end
  
  alias_method :has_a_new_version?, :has_new_version?
  
  def get_uncached_feed
    begin
      @feed = Net::HTTP.start(self.host) { |http| http.get(self.path) }
    rescue => e
      raise FeedError, "Error with feed: #{e}"
    end
  end
  
private

  def store_etag_and_last_modified_on
    store_etag
    store_last_modified_on
  end

  def store_etag
    @stored_etag = etag
  end
  
  def store_last_modified_on
    @stored_last_modified_on = last_modified_on
  end

  def http_session(&block)
    Net::HTTP.start(host, &block)
  end

  def uncompress_feed
    @uncompressed_body = Zlib::GzipReader.inflate @feed.body
    @compressed = false
    return @feed
  end
end
