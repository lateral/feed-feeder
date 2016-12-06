class AddKeyIdToItems < ActiveRecord::Migration
  def change
    add_reference :items, :key, index: true, foreign_key: true
  end
end
