module YunPian
  class TemplateContent
    def self.get_invite_sms(name, site_url)
      "您的好友#{name}邀请您加入Robin8 #{site_url}"
    end
  end
end
