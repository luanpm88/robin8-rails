require 'roo'
begin
  xlsx = Roo::Spreadsheet.open("#{Rails.root}/public/geometry.xlsx")
  phone = xlsx.column(5)
  phone.each do |t|
	kol = Kol.find_by(mobile_number: t)
	if kol.present?
	  kol.admintags << Admintag.find_or_create_by(tag: 'geometry')
	end
  end
  puts "标签打完了哟"
rescue
  puts "出错,请重试"
end
