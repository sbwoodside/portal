require 'feed_tools'

# TODO: needs a cache, and I'm not keen on running FeedUpdater daemon just for this...
# maybe http://www.google.com/search?q=feedtools+database&hl=en ?

class PortalController < ApplicationController
  layout 'site', :except => ['everything_feed']
  
  # main page of the site
  # are there better ways of doing this? probably. do many ways work? no.
  # be very afraid of messing with the data returned by FeedNormalizer
  # and render_to_string of the RSS rxml doesn't work either
  def index
    files = Dir[ "#{RAILS_ROOT}/public/feed-temp/*.xml" ] # grab all of the cron-generated feed files
    uris = files.map { |file| "file:/#{file}" } # convert file paths to file: URIs
    # Here you should make a map between the "official" feed title in the XML, and what you want to show.
    title_map = { "Simon Says" => "Simon Says:", "Simon Says: Comments" => "Simon Says Comment:",
                  "Uploads from sbwoodside" => "Flickr Picture:", "Semacode" => "Semacode Blog:"}
    @all = aggregate_feeds uris, title_map
  end
  
  def everything_feed
    list # compiles the complete list into @all which is an array
    # use @all[0]['obj'] to get the 1st FeedNormalizer entry etc.
    render :template => 'feeds/everything'
  end

private
  # Returns an array of hashes, each hash is { :title, :feed_item }
  # Where :title is a string for the UI, and :feed_item is a FeedTools:FeedItem object
  def aggregate_feeds( uris, title_map )
    all_feed_items = uris.map { |uri| get_feed( uri ) } .flatten # get all of the feed data
    all_feed_items.each { |item| item[:title] = title_map[item[:title]] } # map the feed's title to our favored title
    all_feed_items = all_feed_items.sort_by { |x| x[:feed_item].published }.reverse # sort by date published
  end
  
  def get_feed( uri )
    puts "getting feed #{uri}" # it can be a bit slow
    feed = FeedTools::Feed.open( uri )
    feed.items.map { |feed_item| { :title => feed.title, :feed_item => feed_item } }
  rescue
    logger.warn "**** Error: get_feed threw an exception, but I'm going to continue anyway." and return []
  end
  
end
