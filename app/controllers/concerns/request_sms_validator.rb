module Concerns
  module RequestSmsValidator
    extend ActiveSupport::Concern

    included do
      helper_method :sms_remaining_seconds
    end

    protected

    def sms_remaining_seconds
      seconds = (session[:sms_sent_at].to_i + 60 - Time.now.to_i)
      return nil if seconds <= 0
      seconds
    end

    def sms_request_is_valid_for_login_user?
      unless current_kol
        Rails.logger.sms_spider.error "用户没有登录, #{cookies[:_robin8_visitor]}"
        return false
      end

      key = "kol_#{current_kol.id}_send_sms_count"
      send_count =  Rails.cache.fetch(key).to_i || 1
      Rails.cache.write(key, send_count + 1, :expires_in => 360.seconds)

      Rails.logger.sms_spider.error "kol #{current_kol.id}, tel #{current_kol.mobile_number} send sms #{send_count}"

      return false if send_count > 20
      return true
    end

    def sms_request_is_valid?
      Rails.logger.sms_spider.error '-'*60

      Rails.logger.sms_spider.error 'remote_ip: ' + request.remote_ip
      Rails.logger.sms_spider.error 'ip: ' + request.ip
      Rails.logger.sms_spider.error 'user_agent: ' + request.user_agent
      Rails.logger.sms_spider.error 'referer: ' + request.referer
      Rails.logger.sms_spider.error 'cookie: ' + cookies[:_robin8_visitor]
      Rails.logger.sms_spider.error 'csrf_token: ' + request.env["HTTP_X_CSRF_TOKEN"]

      Rails.logger.sms_spider.error '-'*60

      ips = Rails.cache.fetch("spider_ip_from_kol_6579")


      ip_key = "#{request.ip}_visitor_count"
      send_count =  Rails.cache.fetch(ip_key).to_i || 1

      if ips && ips.include?(request.ip)
        Rails.logger.sms_spider.error ("#{request.ip} 已经尝试#{send_count} 次, 且存在在爬虫黑名单中")
        return false
      end

      Rails.logger.sms_spider.error ("#{request.ip} 已经尝试#{send_count} 次")
      Rails.cache.write(ip_key, send_count + 1, :expires_in => 360.seconds)

      key = cookies[:_robin8_visitor] + "send_sms"
      send_count =  Rails.cache.fetch(key).to_i || 1
      Rails.logger.sms_spider.error (cookies[:_robin8_visitor] + "已经尝试#{send_count} 次")
      Rails.cache.write(key, send_count + 1, :expires_in => 360.seconds)

      if send_count > 10
        Rails.logger.sms_spider.error (cookies[:_robin8_visitor] + "被禁封, 已经尝试#{send_count} 次")
        return false
      end
      if request.user_agent == "Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0)"
        Rails.logger.sms_spider.error (cookies[:_robin8_visitor] + "被禁封, 已经尝试#{send_count} 次, user_agent #{request.user_agent}")
        return false
      end
      return true
    end
  end
end