require 'roo'
require 'csv'
begin
  xlsx = Roo::Spreadsheet.open("#{Rails.root}/public/geometry.xlsx")
  geometry = File.new("#{Rails.root}/public/geometry.txt","w+")
  geometry2 = File.new("#{Rails.root}/public/geometry2.txt","w+")
  phone = xlsx.column(5)
  phone.each do |t|
	  kol = Kol.find_by(mobile_number: t)
	  if kol.present?
	    kol.admintags << Admintag.find_or_create_by(tag: 'geometry') if kol.admintags.blank?
      geometry2.write("#{t},")
    else
      geometry.write("#{t},")
	  end
  end
  geometry.close
  puts "标签打完了哟"
rescue
  puts "出错,请重试"
end