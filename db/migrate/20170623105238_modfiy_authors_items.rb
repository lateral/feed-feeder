class ModfiyAuthorsItems < ActiveRecord::Migration
  def change
    add_foreign_key :authors_items, :items
    add_foreign_key :authors_items, :authors
    add_reference :authors_items, :key, index: true, foreign_key: true
  end
end
