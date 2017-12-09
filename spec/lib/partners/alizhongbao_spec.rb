require 'rails_helper'

describe Partners::Alizhongbao do
  describe "self.signature" do
    it "should sign the params properly" do

      # 从阿里众包 Test.java 拿过来的参数，用来测试
      must_params = {}
      must_params[:method]         = "alizhongbao.api.work.create"
      must_params[:version]        = "1.0"
      must_params[:appId]          = "10009"
      must_params[:sign_type]      = "RSA"
      must_params[:notify_url]     = ""
      must_params[:charset]        = "UTF-8"
      must_params[:requestChannel] = "1"
      must_params[:timestamp]      = "2017-11-03 14:22:11"
      must_params[:format]         = "json"
      must_params[:auth_token]     = ""
      must_params[:alizb_sdk]      = "sdk-java-20161213"

      app_params = {}
      app_params[:userId]       = "28BF5CA24C219B59"
      app_params[:name]         = "API测试工作"
      app_params[:brief]        = "API测试工作"
      app_params[:maxNum]       = "10"
      app_params[:pay]          = "1000"
      app_params[:catId]        = "76"
      app_params[:applyTaskUrl] = "https://www.baidu.com/"
      app_params[:outerId]      = "123456"
      app_params[:offlineTime]  = "2017-11-11 23:59:59"

      expect(Partners::Alizhongbao.sign(must_params.merge(app_params))).
        to eq "TabQNPiXPSRKmXxuxFp7MNvYXEmHynUXkssL7PgghIre7yeq4/xGNiONu55jN+Mc/xtjMfbRgjGUQfzkDChNg/FRc8KHJbogTZGjcwVznACgDhTXgmc7Ex49ja90xMWDUNu9rtRIfLkV4pfGLjp1yQOEz7FRDxPVSqh1pAoQtx4="
    end
  end
end
