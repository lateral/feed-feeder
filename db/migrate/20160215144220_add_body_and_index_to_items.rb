class AddBodyAndIndexToItems < ActiveRecord::Migration
  def change
    add_column :items, :body, :text
    add_index :items, [:feed_source_id, :guid], unique: true
  end
end
