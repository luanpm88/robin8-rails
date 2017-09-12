require 'roo'
begin
	xlsx = Roo::Spreadsheet.open("#{Rails.root}/public/geometry.xlsx")
	phone = xlsx.column(5)
	phone.each do |t|
	  kol = Kol.find_by(mobile_number: t)
	  tags = kol.admintags
	  if tags.count > 1
	    tags.each do |f|
	  	  f.destroy if f.tag == "geometry"
	    end
	    kol.admintags << Admintag.find_or_create_by(tag: 'geometry') if kol.admintags.blank?
	  end
	end
	puts "ok"
rescue
	puts "出错"
end