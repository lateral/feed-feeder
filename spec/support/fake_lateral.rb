require 'sinatra/base'

module FakeLateralHelper
  def init_fake_lateral!
    fake_lateral = FakeLateral.new(key: 'test')
    @results = fake_lateral.instance_variable_get(:@instance).instance_variable_get(:@results)
    @documents = fake_lateral.instance_variable_get(:@instance).instance_variable_get(:@documents)
    stub_request(:any, /api.lateral.io/).to_rack(fake_lateral)
  end
end

RSpec.configure do |config|
  config.include FakeLateralHelper
end

class FakeLateral < Sinatra::Base
  def initialize(hash = {})
    @key = hash[:key]
    @documents = []
  end

  post '/documents/?' do
    content_type :json
    status 200
    params = JSON.parse(request.env['rack.input'].read)
    params[:id] = rand(0...100_000_000)
    @documents << params
    params.to_json
  end

  put '/documents/:id/?' do
    content_type :json
    status 200
    # params.merge!(id: params[:id])
    params.to_json
  end

  delete '/documents/:id/?' do
    content_type :json
    status 200
    # params.merge!(id: params[:id])
    params.to_json
  end

  get '/documents/:id/?' do
    content_type :json
    status 200
    @documents.find { |doc| doc[:id] == params['id'].to_i }.to_json
  end

  post '/documents/similar-to-text/?' do
    content_type :json
    status 200
    10.times.map do |doc|
      { id: rand(0...100_000_000), similarity: 0.001 }
    end.to_json
  end
end
