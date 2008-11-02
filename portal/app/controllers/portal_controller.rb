require 'feed_tools'
require 'timed_fragment_cache'

class PortalController < ApplicationController
  layout 'site', :except => ['everything_feed']
  
  # main page of the portal
  # FeedTools has the advantage of handling messed up feeds
  def index
    @cache_ttl = 60.minutes # should use class variable but it doesn't work
    when_fragment_expired 'aggregate', @cache_ttl.from_now do
      # This is the array of feeds you want to aggregate
      uris = ['http://simonwoodside.com:8080/posts/rss', 'http://simonwoodside.com/comments/rss',
              'http://semacode.com/posts/rss',
              'http://api.flickr.com/services/feeds/photos_public.gne?id=20938094@N00&lang=en-us&format=rss_200',
              'http://api.flickr.com/services/feeds/activity.gne?user_id=20938094@N00']
      # Here you should make a map between the "official" feed title in the XML, and what you want to show on the portal
      title_map = { "Simon Says" => "Simon Says post:", "Simon Says: Comments" => "Simon Says comment:",
                    "Uploads from sbwoodside" => "Flickr picture:", "Semacode" => "Semacode blog post:",
                    'Comments on your photostream and/or sets' => 'Flickr comment:' }
      @all = aggregate_feeds uris, title_map
    end
  end
  
  def everything_feed #TODO FIX
    list # compiles the complete list into @all which is an array
    render :template => 'feeds/everything'
  end

private
  # Returns an array of hashes, each hash is { :title, :feed_item }
  # Where :title is a string for the UI, and :feed_item is a FeedTools:FeedItem object
  def aggregate_feeds( uris, title_map )
    all_feed_items = uris.map { |uri| get_feed( uri ) } .flatten # get all of the feed data
    all_feed_items.each { |item| title_map[item[:title]] && item[:title] = title_map[item[:title]] } # map the feed's title to our favored title
    all_feed_items = all_feed_items.sort_by { |x| x[:feed_item].published }.reverse # sort by date published
  end
  
  def get_feed( uri )
    puts "getting feed #{uri}" # this can be VERY slow
    feed = FeedTools::Feed.open( uri )
    feed.items.map { |feed_item| { :title => feed.title, :feed_item => feed_item } }
  rescue
    logger.warn "**** Error: get_feed threw an exception, but I'm going to continue anyway." and return []
  end
  
end