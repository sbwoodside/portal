require 'feed_tools'
require 'timed_fragment_cache'

class PortalController < ApplicationController
  layout 'site'
  # Instructions: 1. Change @@secret. 2. Add a cron job to regularly call /?recache=yes&secret=XXXXXXX
  # This is a feed aggregator that uses FeedTools because it handles practically any feed.
  # But FeedTools is super slow so this aggregator caches the _parsed_ feeds in the database.
  # TODO add XML feed output
  
  @@secret = "8_2BGh0" # change this to protect your site from DoS attack
  # The array of feeds you want to aggregate. If you change this then manually delete the whole cache.
  @@uris = ['http://simonwoodside.com:8080/posts/rss', 'http://simonwoodside.com/comments/rss',
            'http://semacode.com/posts/rss',
            'http://api.flickr.com/services/feeds/photos_public.gne?id=20938094@N00&lang=en-us&format=rss_200',
            'http://api.flickr.com/services/feeds/activity.gne?user_id=20938094@N00']
  # A map between the "official" feed titles in the XML, and the titles you want to show when rendered.
  @@title_map = { "Simon Says" => "Simon Says:", "Simon Says: Comments" => "Simon Says comment:",
                  "Uploads from sbwoodside" => "Flickr picture:", "Semacode" => "Semacode blog post:",
                  'Comments on your photostream and/or sets' => 'Flickr comment:' }
  
  def index
    if params[:recache] and @@secret == params[:secret]
      cache_feeds
      expire_fragment(:controller => 'portal', :action => 'index') # next load of index will re-fragment cache
      render :text => "Done recaching feeds"
    else
      @all = read_cache unless read_fragment({})
    end
  end
  
private
  # This will replace cached feeds in the DB that have the same URI. Be careful not to tie up the DB connection.
  def cache_feeds
    puts "caching feeds... (can be slow)"
    results = @@uris.map { |uri| {:uri => uri, :parsed_feed => FeedTools::Feed.open( uri )} }
    results.each { |result| CachedFeed.find_or_create_by_uri( result[:uri], :parsed_feed => result[:parsed_feed] ) } # not sure if this does an update...
  end
  # Make an array of hashes, each hash is { :title, :feed_item (FeedTools:FeedItem object) }
  def read_cache
    all = @@uris.map { |uri| get_feed( uri ) } .flatten # get all of the feed data
    all.each { |item| @@title_map[item[:title]] && item[:title] = @@title_map[item[:title]] } # map the feed's title to our favored title
    return all.sort_by { |x| x[:feed_item].published }.reverse # sort by date published
  end
  def get_feed( uri )
    parsed_feed = CachedFeed.find_by_uri( uri ).parsed_feed
    parsed_feed.items.map { |feed_item| { :title => parsed_feed.title, :feed_item => feed_item } } # implicit return value
  end
end