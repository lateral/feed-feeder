require 'rails_helper'

RSpec.describe ItemsToApi do
  describe "ItemsToApi" do
    it 'calls Item.send_missing_to_api' do
      with_resque do
        allow(Item).to receive(:send_missing_to_api)
        Resque.enqueue(ItemsToApi)
        expect(Item).to have_received(:send_missing_to_api)
      end
    end
  end
end
