require 'roo'

begin
  xlsx = Roo::Spreadsheet.open("#{Rails.root}/public/geometry.xlsx")
  # geometry = File.new("#{Rails.root}/public/geometry.txt","w+")
  # geometry2 = File.new("#{Rails.root}/public/geometry2.txt","w+")
  yizhuce = []
  weizhuce = []
  phone = xlsx.column(5)
  phone.each do |t|
	  kol = Kol.find_by(mobile_number: t)
	  if kol.present?
	    kol.admintags << Admintag.find_or_create_by(tag: 'geometry') if kol.admintags.blank?
      yizhuce.push t.to_i
      # geometry2.write("#{t},")
    else
      weizhuce.push t.to_i
      # geometry.write("#{t},")
	  end
  end
  puts "已注册用户#{yizhuce}"
  puts "=========分割线========="
  puts "未注册用户#{weizhuce}"
  # geometry.close
rescue
  puts "出错,请重试"
end
