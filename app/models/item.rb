# app/models/item.rb
class Item < ActiveRecord::Base
  belongs_to :feed_source
  belongs_to :feed
  include ActionView::Helpers::SanitizeHelper
  def self.send_missing_to_api
    Key.all.each do |key|
      key.feed_sources.each do |feed_source|
        items = feed_source.items.where(sent_to_api: false, rejected_by_api: false)
                           .where("published >= NOW() - '7 days'::INTERVAL")
                           .order('id DESC').limit(250)
        items.each { |item| item.send_to_api(key) }
      end
    end
  end

  def send_to_api(key, from_initial_sync = false)
    return mark_error('Invalid body') if body && body.empty?
    return mark_error('Duplicate') if duplicate?(key)

    data = { text: body }.to_json
    headers = { content_type: :json, 'Subscription-Key' => key.key }
    response = JSON.parse RestClient.post("#{key.endpoint}/documents", data, headers)

    update_attributes(sent_to_api: true, lateral_id: response['id'])

  # Ignore this type of error, wait until next time
  rescue Errno::EHOSTUNREACH
    false
  rescue RestClient::Exception => e
    assign_attributes(rejected_by_api: true)
    mark_error(e.response)
  rescue JSON::ParserError => e
    mark_error(e.response)
  end

  private

  def duplicate?(key)
    data = { text: body }.to_json
    headers = { content_type: :json, 'Subscription-Key' => key.key }
    response = JSON.parse(RestClient.post("#{key.endpoint}/documents/similar-to-text", data, headers))
    response.is_a?(Array) && response.present? && response[0]['similarity'] > 0.99
  end

  def mark_error(error)
    begin
      JSON.parse(error)
    rescue JSON::ParserError, Oj::ParseError => e
      error = { message: error }.to_json
    end

    update_attributes(sent_to_api: true, error: error)
  end
end
