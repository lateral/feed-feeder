require 'resque/scheduler/server'

Rails.application.routes.draw do
  get 'feeds/:id' => 'feeds#webhook_subscribe'
  post 'feeds/:id' => 'feeds#webhook_update'

  # Mount resque and protect it for production
  mount Resque::Server.new, at: '/administration/resque'

  root to: 'application#index'
end
