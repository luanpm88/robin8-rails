require 'roo'
require 'csv'
begin
  xlsx = Roo::Spreadsheet.open("#{Rails.root}/public/geometry2.xlsx")
  geometry = File.new("#{Rails.root}/public/geometry2.txt","w+")
  geometry3 = File.new("#{Rails.root}/public/geometry3.txt","w+")
  phone = xlsx.column(2)
  phone.each do |t|
    kol = Identity.find_by(name: t)
    unless kol.present?
      geometry.write("#{t},") 
    else
      geometry3.write("#{t},") 
    end
  end
  geometry.close
  geometry3.close
  puts "查完收工"
rescue
  puts "出错,请重试"
end
