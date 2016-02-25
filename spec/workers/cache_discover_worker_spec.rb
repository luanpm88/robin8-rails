require 'rails_helper'

RSpec.describe CacheDiscoverWorker do
  it { is_expected.to be_retryable false }

  describe '#perform' do
    before :each do
      Rails.cache.delete_matched 'discover:kol_id_*'
    end

    it 'write fetched discovers to redis' do
      identity = FactoryGirl.create :weibo_identity
      kol = identity.kol

      expect{
        CacheDiscoverWorker.new.perform kol.id
      }.to change{
        Rails.cache.read("discover:kol_id_#{kol.id}").nil?
      }.from(true).to(false)
    end

    it 'cached discovers is a Hash and contains timestamp' do
      identity = FactoryGirl.create :weibo_identity
      kol = identity.kol

      CacheDiscoverWorker.new.perform kol.id

      value = Rails.cache.read "discover:kol_id_#{kol.id}"
      expect(value).to be_a Hash
      expect(value[:timestamp]).to be_a DateTime
    end
  end

  describe '.encode_labels_url_for' do
    it 'returns encoded url for weibo identity' do
      identity = FactoryGirl.create :weibo_identity

      url = CacheDiscoverWorker.encode_labels_url_for identity
      expect(url).to eq "#{Rails.application.secrets.data_engine_url[:weibo]}/#{identity.uid}"
    end

    it 'returns encoded url for wechat-third identity' do
      identity = FactoryGirl.create :wechat_third_identity

      url = CacheDiscoverWorker.encode_labels_url_for identity
      expect(url).to eq URI.encode("#{Rails.application.secrets.data_engine_url[:wechat]}/code/#{identity.alias}/name/#{identity.name}")
    end
  end

  describe '.encode_discovers_url_for' do
    it 'returns url' do
      labels = ['internet', 'jd', 'career']
      url = CacheDiscoverWorker.encode_discovers_url_for labels, 1

      expect(url).to eq "#{Rails.application.secrets.data_engine_url[:discover]}/page/1?labels=internet,jd,career"
    end

    it 'returns all labels url(no labels param) for labels empty' do
      labels = []
      url = CacheDiscoverWorker.encode_discovers_url_for labels, 1

      expect(url).to eq "#{Rails.application.secrets.data_engine_url[:discover]}/page/1"
    end
  end

  describe '.request_labels_by' do
    it 'return empty array for invaild identity' do
      identities = []
      identities << Identity.new(provider: 'weibo', uid: '11111111', kol: Kol.new)

      result = CacheDiscoverWorker.request_labels_by identities
      expect(result).to eq []
    end
  end

  describe '.tell_staff_error_when_request' do

    it 'ping slack to tell staff request error' do
      result = CacheDiscoverWorker.tell_staff_error_when_request 'url', 'error_message'
      expect(result.code).to eq "200"
    end
  end

  describe '.request_discovers_by' do

  end

  describe '.request' do

  end

  describe '.write_rails_cache' do
    before :each do
      Rails.cache.delete_matched 'test:*'
    end

    it 'returns true' do
      result = CacheDiscoverWorker.write_rails_cache 'test:key', 'value'

      expect(result).to be_truthy
    end

    it 'write rails cache with true value' do
      expect {
        CacheDiscoverWorker.write_rails_cache 'test:key', 'value'
      }.to change {
        Rails.cache.read 'test:key'
      }.from(nil).to('value')
    end

    it 'set expires_in' do
      CacheDiscoverWorker.write_rails_cache 'test:expires_soon', 'value', 1.hours

      # for Rails.cache use 'robcache' namespace, no Rails.cache called manually add 'robcache'
      expires_in = `redis-cli TTL 'robcache:test:expires_soon'`
      expect(expires_in.to_i).to eq 1.hours.to_i
    end

    it 'default expires_in 1.months' do
      CacheDiscoverWorker.write_rails_cache 'test:expires_soon', 'value'

      expires_in = `redis-cli TTL 'robcache:test:expires_soon'`
      expect(expires_in.to_i).to eq 1.months.to_i
    end
  end
end
