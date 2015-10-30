module Concerns
  module BrowserRequest
    extend ActiveSupport::Concern

    def is_weixin_request?
      request.user_agent.downcase.match(/micromessenger/)    rescue false
    end

    def is_360_request?
      request.user_agent.downcase.match(/360 aphone browser/)    rescue false
    end

    def is_wp_request?
      request.user_agent.downcase.match(/wpdesktop/)     rescue false
    end

    def is_ios_request?
      request.user_agent.downcase.match(/ipad|iphone/)    rescue false
    end

    def is_safari_request?
      request.user_agent.downcase.match(/safari/)       rescue false
    end

    def is_android_request?
      request.user_agent.downcase.match(/android/)      rescue false
    end

    def mobile_request?
      if is_android_request? || is_ios_request? || is_weixin_request?
        return true
      else
        return false
      end
    end

  end
end
