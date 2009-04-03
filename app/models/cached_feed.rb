require 'feed_tools'
class CachedFeed < ActiveRecord::Base
  validates_presence_of :uri, :parsed_feed
  validates_uniqueness_of :uri
  serialize :parsed_feed, Hash # note that if this exceeds a certain KB size, it will likely fail (thinking it's a String)
end
