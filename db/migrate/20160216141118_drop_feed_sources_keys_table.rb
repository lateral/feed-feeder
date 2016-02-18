class DropFeedSourcesKeysTable < ActiveRecord::Migration
  def change
    drop_table :feed_sources_keys

    add_reference :feed_sources, :key, index: true, foreign_key: true
  end
end
