class AddIndexToAuthors < ActiveRecord::Migration
  def change
    add_index :authors, :name, unique: true
    add_index :authors, :hash_id, unique: true
  end
end
