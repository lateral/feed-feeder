class AddIndexesToAuthorsItems < ActiveRecord::Migration
  def change
    add_index :authors_items, :item_id
    add_index :authors_items, :author_id
  end
end
