class RemoveBodyFromItems < ActiveRecord::Migration
  def change
    remove_column :items, :body
  end
end
