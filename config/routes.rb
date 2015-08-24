require 'resque/scheduler/server'

Rails.application.routes.draw do
  resources :feeds

  # Mount resque and protect it for production
  mount Resque::Server.new, at: '/administration/resque'

  root to: 'application#index'
end
