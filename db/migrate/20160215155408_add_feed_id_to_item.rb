class AddFeedIdToItem < ActiveRecord::Migration
  def change
    add_reference :items, :feed, index: true, foreign_key: true
  end
end
