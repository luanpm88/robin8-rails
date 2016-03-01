require 'slack-notifier'

class CacheDiscoverWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false, :queue => :cache_discover

  def perform kol_id
    Rails.logger.sidekiq.info "Started perform #{self.class.to_s} with kol_id: #{kol_id}"

    kol = Kol.where(id: kol_id).first

    unless kol
      Rails.logger.sidekiq.error "Abort perform #{self.class.to_s} failed: kol id #{kol_id} not existed"
      return
    end

    identities = kol.identities.where(:provider => ['weibo', 'wechat_third'])

    labels = CacheDiscoverWorker.request_labels_by identities

    discovers = CacheDiscoverWorker.request_discovers_by labels
    CacheDiscoverWorker.asset_path discovers

    key = "discover:kol_id_#{kol.id}"
    value = {
      :discovers => discovers,
      :timestamp => DateTime.now
    }
    cached_ok = CacheDiscoverWorker.write_rails_cache key, value

    unless cached_ok
      Rails.logger.sidekiq.error "Perform #{self.class.to_s} faild: kol id #{kol_id}, write to cache failed!"
      return
    end

    Rails.logger.sidekiq.info "Completed perform #{self.class.to_s} with kol_id: #{kol_id}"
  end

  def self.encode_labels_url_for identity
    url = case identity.provider
          when 'weibo'
            "#{Rails.application.secrets.data_engine_url[:weibo]}/#{identity.uid}"
          when 'wechat_third'
            "#{Rails.application.secrets.data_engine_url[:wechat]}/code/#{identity.alias}/name/#{identity.name}"
          end
    URI.encode url
  end

  def self.write_rails_cache key, value, expires_in=1.months
    Rails.cache.write(key, value, :expires_in => expires_in).eql?("OK") ? true : false
  end

  def self.encode_discovers_url_for labels, page
    labels_query = labels.empty? ? '' : "?labels=#{labels.join(',')}"
    url = URI.encode "#{Rails.application.secrets.data_engine_url[:discover]}/page/#{page}#{labels_query}"
  end

  def self.request_labels_by identities
    labels = []
    identities.each do |x|
      url = CacheDiscoverWorker.encode_labels_url_for x
      CacheDiscoverWorker.request url do |res|
        labels.concat(res['labels'].map { |x| x['name']})
      end
    end

    custom_labels = identities.map do |x|
      x.iptc_categories.map { |x| x.name }
    end

    labels.concat custom_labels.flatten
    labels.uniq.compact
  end

  def self.request_discovers_by labels
    discovers = []
    # todo fix hard code
    5.times do |n|
      page = n + 1

      url = CacheDiscoverWorker.encode_discovers_url_for labels, page
      CacheDiscoverWorker.request url do |res|
        discovers.concat res['articles']
      end
    end

    discovers
  end

  def self.request url
    begin
      res = RestClient::Request.execute(:method => :get,
                                        :url => url, 
                                        :timeout => 5,
                                        :open_timeout => 5, 
                                        :user => Rails.application.secrets.data_engine_url[:user], 
                                        :password => Rails.application.secrets.data_engine_url[:password])
      case res.code
      when 200
        json_res = JSON.parse res
        if json_res['return_code'].eql?(0)
          yield json_res if block_given?
        else
          raise 'Not found'
        end
      end
    rescue => e
      Rails.logger.sidekiq.error "something was wrong when request: #{url}, error msg: #{e.message}"
      CacheDiscoverWorker.tell_staff_error_when_request url, e.message
      return
    end
  end

  def self.tell_staff_error_when_request url, message
    # todo move slack webhook url to secrets.yml
    notifier = Slack::Notifier.new 'https://hooks.slack.com/services/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'

    notifier.ping "[#{Rails.env}] fetching `#{url}` failed, message: `#{message}`"
  end

  def self.asset_path discovers
    discovers.each do |discover|
      discover['img_url'] = ActionController::Base.helpers.asset_path('recommendations/' + discover['label'] + (1..6).to_a.sample.to_s + '.png')
    end
  end
end
