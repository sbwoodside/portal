require 'feed_tools'

# This is a feed aggregator that uses FeedTools because it handles practically any feed.
# But FeedTools is super slow in every way so this aggregator stops using it as soon as possible.
# TODO add XML feed output
class PortalController < ApplicationController
  layout 'site'
  
  def index
    puts Conf.title_map.inspect
    if params[:recache] and Conf.secret == params[:secret]
      cache_feeds
      expire_fragment(:controller => 'portal', :action => 'index') # next load of index will re-fragment cache
      render :text => "Done recaching feeds"
    else
      @aggregate = read_cache unless read_fragment({})
    end
  end
  
private
  # This will replace cached feeds in the DB that have the same URI. Be careful not to tie up the DB connection.
  def cache_feeds
    puts "Caching feeds... (can be slow)"
    feeds = Conf.feeds.map do |uri|
      feed = FeedTools::Feed.open( uri )
      { :uri => uri, :title => feed.title, 
        :items => feed.items.map { |item| {:title => item.title, :published => item.published, :link => item.link} } }
    end
    feeds.each { |feed|
      new = CachedFeed.find_or_initialize_by_uri( feed[:uri] )
      new.parsed_feed = feed
      new.save!
    }
  end
  # Make an array of hashes, each hash is { :title, :feed_item }
  def read_cache
    Conf.feeds.map { |uri|
      feed = CachedFeed.find_by_uri( uri ).parsed_feed
      feed[:items].map { |item| {:feed_title => Conf.title_map[feed[:title]] || feed[:title], :feed_item => item} }
    } .flatten .sort_by { |item| item[:feed_item][:published] } .reverse
  end
end
