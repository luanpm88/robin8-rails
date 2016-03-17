module Emay
  class TemplateContent
    Pre = "【Robin8中国】"
    TD = ' 回复TD退订'
    def self.get_content(content)
      "#{Pre}#{content}#{TD}"
    end

    def self.get_invite_sms(name, url)
      "Robin8全球第一影响力管理平台，#{name || '我'}已经加入了，你也来测测你的影响力价值吧！下载APP：#{url}"
    end
  end
end
