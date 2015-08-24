class AddColumnsToFeed < ActiveRecord::Migration
  def change
    add_column :feeds, :status, :integer, :default => :unsubscribed
    add_column :feeds, :expiration_date, :datetime
    add_column :feeds, :error_msg, :string
  end
end
