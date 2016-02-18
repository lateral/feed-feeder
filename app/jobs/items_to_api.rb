# app/jobs/items_to_api.rb
require 'resque/plugins/lock'

class ItemsToApi
  extend ResquePostgresDisconnect
  extend Resque::Plugins::Lock
  @queue = :items_to_api

  def self.perform
    Item.send_missing_to_api
  end
end
