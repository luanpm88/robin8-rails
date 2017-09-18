require 'roo'
require 'csv'
begin
  xlsx = Roo::Spreadsheet.open("#{Rails.root}/public/geometry2.xlsx")
  geometry = File.new("#{Rails.root}/public/geometry2.txt","w+")
  phone = xlsx.column(2)
  phone.each do |t|
	kol = Identity.find_by(name: t)
	geometry.write("#{t},") unless kol.present?
  end
  geometry.close
  puts "查完收工"
rescue
  puts "出错,请重试"
end
