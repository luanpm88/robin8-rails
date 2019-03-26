class UserCollectedKol < ActiveRecord::Base
  belongs_to :user
  belongs_to :kol

  def plateform_name_type
    case self.plateform_name
    when 'public_weibo_account'
      0
    when 'public_wechat_account'
      1
    else
      1
    end
  end

  def bigV_url
    trademark = self.user.trademarks.where(status: 1).first

    "/kol/#{plateform_uuid}?type=#{plateform_name == 'public_weibo_account' ? 0 : 1}&brand_keywords=#{trademark.try(:keywords)}"
  end
  
end
