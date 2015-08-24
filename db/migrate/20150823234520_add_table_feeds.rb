class AddTableFeeds < ActiveRecord::Migration
  def change
    create_table :feeds do |t|
      t.integer :feed_source_id
      t.string :url
    end
  end
end
