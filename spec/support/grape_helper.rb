require 'rspec/expectations'

# Functions to help test the grape API
module GrapeHelper
  extend RSpec::Matchers::DSL

  def json_response
    JSON.parse(response.body)
  end

  matcher :not_find do |model, value|
    match do |actual|
      actual.status == 404
    end
    match do |actual|
      @message = JSON.parse(actual.body)['message']
      if value
        @message == "Couldn't find #{model} with 'id'=#{value}"
      else
        @message.include? "Couldn't find all #{model}s"
      end
    end
    failure_message do |actual|
      message = "Couldn't find all #{model}s ...."
      message = "Couldn't find #{model} with 'id'=#{value}" if value
      %(Status:
  expected: 404
       got: #{actual.status}
Message:
  expected: "#{message}"
       got: "#{@message}")
    end
  end
end

RSpec.configure do |config|
  config.include GrapeHelper
end
