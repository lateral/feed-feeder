class AddIndexToPublished < ActiveRecord::Migration
  def change
    add_index :items, :published
  end
end
