class AddRecommendableToItem < ActiveRecord::Migration
  def change
    add_column :items, :recommendable, :boolean, null: true, default: true
  end
end
