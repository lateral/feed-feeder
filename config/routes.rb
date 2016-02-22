require 'resque/scheduler/server'

Rails.application.routes.draw do
  get 'feeds/:id' => 'feeds#webhook_subscribe'
  post 'feeds/:id' => 'feeds#webhook_update'

  get 'administration' => 'application#keys'
  get 'administration/:key_id' => 'application#feed_sources'
  get 'administration/:key_id/feed-source/:feed_source_id' => 'application#feeds'
  mount Resque::Server.new, at: '/administration/resque'

  root to: 'application#index'
end
