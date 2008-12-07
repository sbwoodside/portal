require 'feed_tools'
require 'timed_fragment_cache'

class PortalController < ApplicationController
  layout 'site'
  # We use FeedTools because it can handle messed up feeds. BUT, it's REALLY slow, so we should almost always
  # read from a (database/rails) cache. Also cache the PARSED data, not the xml data.
  # TODO add XML feed output
  
  @@secret = "8_2BGh0" # change this to protect your site from DoS attack
  # This is the array of feeds you want to aggregate.
  # Currently if you change this you need to manually delete all the records in the cache
  @@uris = ['http://simonwoodside.com:8080/posts/rss', 'http://simonwoodside.com/comments/rss',
            'http://semacode.com/posts/rss',
            'http://api.flickr.com/services/feeds/photos_public.gne?id=20938094@N00&lang=en-us&format=rss_200',
            'http://api.flickr.com/services/feeds/activity.gne?user_id=20938094@N00']
  # Here you should make a map between the "official" feed title in the XML, and what you want to show on the portal
  @@title_map = { "Simon Says" => "Simon Says:", "Simon Says: Comments" => "Simon Says comment:",
                  "Uploads from sbwoodside" => "Flickr picture:", "Semacode" => "Semacode blog post:",
                  'Comments on your photostream and/or sets' => 'Flickr comment:' }
  
  #def index # When you want to recache the feeds, call /?recache=yes. do that regularly from cron.
  #  if params[:recache] and @@secret == params[:secret]
  #    puts "SIMON -------- ABOUT TO START RECACHE"
  #    @@uris.each { |uri| cache_feed uri } # while this is running, the existing cache should still be used
  #    puts "SIMON -------- DONE RECACHE ABOUT TO EXPIRE FRAGMENT"
  #    expire_fragment(:controller => 'portal', :action => 'index')
  #  end
  #  unless read_fragment({})
  #    # Make an array of hashes, each hash is { :title, :feed_item (FeedTools:FeedItem object) }
  #    @all = @@uris.map { |uri| get_feed( uri ) } .flatten # get all of the feed data
  #    @all.each { |item| @@title_map[item[:title]] && item[:title] = @@title_map[item[:title]] } # map the feed's title to our favored title
  #    @all = @all.sort_by { |x| x[:feed_item].published }.reverse # sort by date published
  #  end
  #end
  def index # When you want to recache the feeds, call /?recache=yes. do that regularly from cron.
    if params[:recache]
      puts "SIMON -------- ABOUT TO START RECACHE"
      @@uris.each { |uri| cache_feed uri }
      puts "SIMON -------- DONE RECACHE ABOUT TO READ CACHE"
      @all = read_cache
      puts "SIMON -------- DONE READ CACHE ABOUT TO EXPIRE FRAGMENT"
      expire_fragment(:controller => 'portal', :action => 'index')
      puts "SIMON -------- DONE EXPIRE FRAGMENT"
    else
      unless read_fragment({})
        @all = read_cache
      end
    end
  end
  
private
  # Make an array of hashes, each hash is { :title, :feed_item (FeedTools:FeedItem object) }
  def read_cache
    all = @@uris.map { |uri| get_feed( uri ) } .flatten # get all of the feed data
    all.each { |item| @@title_map[item[:title]] && item[:title] = @@title_map[item[:title]] } # map the feed's title to our favored title
    return all.sort_by { |x| x[:feed_item].published }.reverse # sort by date published
  end
  # This will replace cached feeds in the DB that have the same URI
  def cache_feed( uri )
    puts "cache_feed( #{uri} )" # this can be VERY slow
    new = CachedFeed.find_or_initialize_by_uri( uri )
    new.parsed_feed = FeedTools::Feed.open( uri )
    new.save!
  end
  def get_feed( uri )
    parsed_feed = CachedFeed.find_by_uri( uri ).parsed_feed
    parsed_feed.items.map { |feed_item| { :title => parsed_feed.title, :feed_item => feed_item } } # implicit return value
  rescue
    puts "**** Error: get_feed threw an exception (#{$!}), but I'm failing gracefully." and return []
  end
  
end