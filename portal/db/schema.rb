# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 1) do

  create_table "cached_feeds", :force => true do |t|
    t.string   "href"
    t.string   "title"
    t.string   "link"
    t.text     "feed_data"
    t.string   "feed_data_type"
    t.text     "http_headers"
    t.datetime "last_retrieved"
    t.integer  "time_to_live"
    t.text     "serialized"
  end

  add_index "cached_feeds", ["href"], :name => "index_cached_feeds_on_href"

end
