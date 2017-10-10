require 'roo'

begin
  old_number = Roo::Spreadsheet.open("#{Rails.root}/public/rodirgo.xlsx").column(1)
  xinyonghu = []
  kols = CampaignInvite.where(campaign_id: 4221)
  all = kols.map {|t| t.kol.mobile_number}
  kols.each do |t|
    t.kol.admintags << Admintag.find_or_create_by(tag:'Rodirgo') if t.kol.admintags.blank?
    xinyonghu.push t.kol.mobile_number unless old_number.include?(t.kol.mobile_number)
  end

  puts "所有用户#{all}"
  puts "=========分割线========="
  puts "新用户#{xinyonghu}"
rescue
  puts '出错了，请检查'
end
