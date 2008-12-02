class CreateCachedFeeds < ActiveRecord::Migration
  def self.up
    create_table :cached_feeds do |t|
      t.column :uri, :string, :limit => 2048
      t.column :parsed_feed, :text, :limit => 128.kilobytes # use for serialized object
      t.timestamps
    end
  end

  def self.down
    drop_table :cached_feeds
  end
end
