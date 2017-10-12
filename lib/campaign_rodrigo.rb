require 'roo'

begin
  old_number = Roo::Spreadsheet.open("#{Rails.root}/public/rodrigo.xlsx").column(1)

  #number = []
  #找出10月6号和7号这两天新注册的用户
  kols = Kol.where("created_at > ? and created_at < ?","2017-10-06 00:00:00" ,"2017-10-07 23:59:59")
  #puts kols
  ids = []
  kols.each do |t|
    #判断这两天新注册的用户是否参加了4221这个活动
    cam = CampaignInvite.find_by(campaign_id: 4221, kol_id: t.id)
    if cam.present? && t.admintags.blank?
      t.admintags << Admintag.find_or_create_by(tag:'Rodrigo')
      ids.push t.mobile_number.to_i unless old_number.include?(t.mobile_number)
    end
  end

  #kols = CampaignInvite.where(campaign_id: 4221 ).kols.where("created_at >= ? and created_at <= ?","2017-10-06 00:00:00" ,"2017-10-07 23:59:59")
  #
  # all = kols.map {|t| t.kol.mobile_number.to_i}
  # kols.each do |t|
  # #  t.kol.admintags << Admintag.find_or_create_by(tag:'Rodrigo') if t.kol.admintags.blank?
  #   # xinyonghu.push t.kol.mobile_number unless old_number.include?(t.kol.mobile_number)
  # end

  #puts "所有用户#{all}"
  #puts "=========分割线========="
  puts "新用户#{ids}"
rescue
  puts '出错了，请检查'
end
