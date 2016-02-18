class RenameSomeFields < ActiveRecord::Migration
  def change
    rename_column :items, :rejected_from_api, :rejected_by_api
    rename_column :items, :api_response, :error
  end
end
