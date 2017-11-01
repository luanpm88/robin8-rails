require 'roo'
require 'csv'
begin
  xlsx = Roo::Spreadsheet.open("#{Rails.root}/public/baoma.xlsx")
  geometry = File.new("#{Rails.root}/public/baoma.txt","w+")
  phone = xlsx.column(3)
  phone.each do |t|
	  kol = Kol.find_by(mobile_number: t)
	  if kol.present?
	    kol.admintags << Admintag.find_or_create_by(tag: 'baby_mommy')
    else
      geometry.write("#{t},")
	  end
  end
  geometry.close
  puts "标签打完了哟"
rescue
  puts "出错,请重试"
end
