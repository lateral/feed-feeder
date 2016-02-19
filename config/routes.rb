require 'resque/scheduler/server'

Rails.application.routes.draw do
  get 'feeds/:id' => 'feeds#webhook_subscribe'
  post 'feeds/:id' => 'feeds#webhook_update'

  get 'administration' => 'application#administration'
  get 'administration/:id' => 'application#administration_feed'
  mount Resque::Server.new, at: '/administration/resque'

  root to: 'application#index'
end
