class RenameRecommendableToFromInitialSyncInItems < ActiveRecord::Migration
  def change
    rename_column :items, :recommendable, :from_initial_sync
    change_column :items, :from_initial_sync, :boolean, null: false, default: false
  end
end
