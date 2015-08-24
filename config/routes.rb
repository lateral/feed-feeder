require 'resque/scheduler/server'

Rails.application.routes.draw do
  root 'application#index'

  resources :feeds
  
  # Mount resque and protect it for production
  mount Resque::Server.new, at: '/administration/resque'
end
