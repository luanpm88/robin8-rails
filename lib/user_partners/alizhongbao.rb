module Alizhongbao
  def push_campaign
    # 把活动发布到 阿里众包
    ALIZHONGBAO_URL = "http://alibaba.com"

    url = Rails.env.production? ALIZHONGBAO_URL : "http://test.test"

    # body 就参考那个阿里众包api 文档 .docx
    # body

    resp = HTTParty.post(url, body: body,
                         headers: {'Content-Type' => 'application/json'}).parsed_response


  end
end
