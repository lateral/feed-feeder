class AddForeignKeys < ActiveRecord::Migration[5.0]
  def change
    add_foreign_key :feeds, :feed_sources
  end
end
