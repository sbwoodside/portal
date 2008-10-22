#!/bin/sh

# You can easily test this by cd'ing to this directory and doing ./update-feeds.sh

set -e

RELATIVE_TEMP_PATH=../../public/feed-temp

wget -nv 'http://simonwoodside.com:8080/posts/rss' -O $RELATIVE_TEMP_PATH/swc.xml
wget -nv 'http://simonwoodside.com/comments/rss' -O $RELATIVE_TEMP_PATH/swc-comments.xml
wget -nv 'http://semacode.com/posts/rss' -O $RELATIVE_TEMP_PATH/semacode.xml
wget -nv 'http://api.flickr.com/services/feeds/photos_public.gne?id=20938094@N00&lang=en-us&format=rss_200' -O $RELATIVE_TEMP_PATH/flickr.xml

# Add any other feeds that you want to read here.