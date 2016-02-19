# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment', __FILE__)

class AdministrationAuth < Rack::Auth::Basic
  def call(env)
    case Rack::Request.new(env).path
    when %r{^\/administration\/}
      super
    else
      @app.call(env)
    end
  end
end

use AdministrationAuth, 'lateral' do |u, p|
  u == 'lateral' && p == ENV['HTTP_AUTH_PASSWORD']
end if Rails.env.production?

run Rails.application
