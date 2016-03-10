require 'rails_helper'

describe Rack::Attack do
  include Rack::Test::Methods

  def app
    Rails.application
  end

  describe 'throttle excessive requests by IP address' do 
    let(:limit) { 1000 }

    before :each do
      Rails.cache.delete_matched "rack::attack*"
    end

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

  describe 'throttle by cookies' do
    let(:limit) { 1000 }

    before :each do
      Rails.cache.delete_matched "rack::attack*"
      clear_cookies
      set_cookie '_robin8_visitor=test_cookies'
    end

    context 'numbers of request is lower than the limit' do
      it 'do nothing' do
        limit.times do
          get '/'

          expect(last_response.status).to_not eq 429
        end
      end
    end

    context 'numbers of request is higher than the limit' do
      it 'returns 429' do
        (limit * 2).times do |i|
          get '/'

          expect(last_response.status).to eq 429 if i > limit
        end
      end
    end
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

      # expect(last_response.status).to eq 403
      #
      # return 503 so that make attacker confused
      expect(last_response.status).to eq 503
    end
  end
end
