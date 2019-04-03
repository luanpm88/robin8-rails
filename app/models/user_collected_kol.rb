class UserCollectedKol < ActiveRecord::Base

  PLATEFORM = {
    weibo:                  0,
    public_wechat_account:  1,
    xiaohongshu:            2,
    kuaishou:               3,
    bilibili:               4,
    douyin:                 5,
    instagram:              6,
    youtube:                7,
    facebook:               8
  }

  belongs_to :user
  belongs_to :kol

  def plateform_name_type
    PLATEFORM[plateform_name.to_sym] || 1
  end

  def bigV_url
    trademark = self.user.trademarks.where(status: 1).first

    "/kol/#{ERB::Util.url_encode(plateform_uuid)}?type=#{plateform_name_type}&brand_keywords=#{trademark.try(:keywords)}"
  end

  def terrace_avatar
    "http://img.robin8.net/#{plateform_name}.png"
  end
  
end
