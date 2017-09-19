# -*- coding: UTF-8 -*-
require 'roo'
require 'csv'

xlsx = Roo::Spreadsheet.open("#{Rails.root}/public/phone.xlsx")
phone = File.new("#{Rails.root}/public/phone.txt","w+")
kol_name =  xlsx.column(2)
puts kol_name
kol_name.each do |t|
  mobile_number = Identity.find_by(name: t).kol.mobile_number
  phone.write("#{mobile_number},")
end
phone.close