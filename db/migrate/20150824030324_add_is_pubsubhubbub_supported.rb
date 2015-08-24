class AddIsPubsubhubbubSupported < ActiveRecord::Migration
  def change
    add_column :feeds, :is_pubsubhubbub_supported, :boolean
  end
end
