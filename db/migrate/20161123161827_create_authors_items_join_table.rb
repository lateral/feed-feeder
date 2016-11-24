class CreateAuthorsItemsJoinTable < ActiveRecord::Migration
  def change
    create_table :authors_items, id: false do |t|
      t.integer :item_id
      t.integer :author_id
    end
  end
end
