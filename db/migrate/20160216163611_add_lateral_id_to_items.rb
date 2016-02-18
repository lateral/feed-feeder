class AddLateralIdToItems < ActiveRecord::Migration
  def change
    add_column :items, :lateral_id, :integer
  end
end
