class Ocr
  def self.get_result(campaign_invite, params)
    ocr_root_path = Rails.application.secrets[:ocr][:root_path]
    logo_name = Rails.application.secrets[:ocr][:logo_name]
    screenshot_name = Rails.application.secrets[:ocr][:screenshot_name]
    invite_floder_path = "#{ocr_root_path}/campaign_invites/#{campaign_invite.id}"
    system("mkdir -p #{invite_floder_path}")
    File.open("#{invite_floder_path}/#{logo_name}", "wb") {|f| f.write(params[:campaign_logo][:tempfile].read) }
    File.open("#{invite_floder_path}/#{screenshot_name}", "wb"){|f| f.write(params[:screenshot][:tempfile].read) }
    # `cd /home/deployer/apps/screenshot_approve && python  find.py /home/deployer/apps/screenshot_approve/images/campaign/campaign.jpg /home/deployer/apps/screenshot_approve/images/wechat_screenshot/wechat_screen_1.jpg `
    result = `cd #{ocr_root_path} && python  find.py #{invite_floder_path}/#{logo_name} #{invite_floder_path}/#{screenshot_name} `    rescue nil
    Rails.logger.info "--campaign_invite_id:#{campaign_invite.id}----result:#{result}"
    if result.present?
      parse_result(result)
    else
     return ['failure', 'unfound']
    end
  end

  def self.parse_result(res)
    most_detail = []
    most_priority = -1
    Rails.logger.info  res.split("\n")[0..-1]
    res.split("\n")[1..-1].each do |item|
      points = item.split(" ")
      priority = 0
      detail = []
      #时间
      if points[0].include?('分钟') && points[0].match(/\d+/)[0].to_i < 30
        detail << 'time'
      else
        priority += 1
      end
      #分组
      if points[1] == "True"
        detail << 'group'
      else
        priority += 1
      end
      #是否自己
      if points[2] == "True"
        priority += 3
      else
        detail << 'owner'
      end
      if priority > most_priority
        most_detail = detail
        most_priority = priority
      end
    end
    Rails.logger.info "-----parse-result:  --#{most_priority} --- #{most_detail}"
    status = (most_priority == 5 ? 'passed' : 'failure')
    return [status, most_detail.join(',')]
  end
end
