require 'roo'
require 'csv'
begin
  xlsx = Roo::Spreadsheet.open("#{Rails.root}/public/geometry.xlsx")
  geometry = File.new("#{Rails.root}/public/#{Time.now}geometry.txt","w+")
  phone = xlsx.column(5)
  phone.each do |t|
    geometry.write("#{t},")
	  kol = Kol.find_by(mobile_number: t)
	  if kol.present?
      geometry.write("#{t},")
	    kol.admintags << Admintag.find_or_create_by(tag: 'geometry')
	  end
  end
  geometry.close
  puts "标签打完了哟"
rescue
  puts "出错,请重试"
end
