class AddIndexToLateralIds < ActiveRecord::Migration
  def change
    add_index :items, :lateral_id
  end
end
