require 'rails_helper'

describe Rack::Attack do
  include Rack::Test::Methods

  def app
    Rails.application
  end

  describe 'throttle excessive requests by IP address' do 
    let(:limit) { 1000 }

    context 'numbers of requests is lower than the limit' do
      it 'do nothing' do
        limit.times do
          get '/', {}, 'REMOTE_ADDR' => '1.2.3.4'

          expect(last_response.status).to_not eq 429
        end
      end
    end

    context 'numbers of requests is higher than the limit' do
      it 'returns 429' do
        (limit * 2).times do |i|
          get '/', {}, 'REMOTE_ADDR' => '1.2.3.5'

          expect(last_response.status).to eq 429 if i > limit
        end
      end
    end

    pending 'not throttle request start_with /assets'
  end

  describe 'blacklisting' do
    before :each do
      Rails.cache.write 'block 1.2.3.4', 'y'
    end

    after :each do
      Rails.cache.delete 'block 1.2.3.4'
    end

    it 'request was blocked when the ip in block list' do
      get '/', {}, 'REMOTE_ADDR' => '1.2.3.4'

      expect(last_response.status).to eq 403
    end
  end
end
