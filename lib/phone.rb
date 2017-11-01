# -*- coding: UTF-8 -*-
require 'roo'
require 'csv'

xlsx = Roo::Spreadsheet.open("#{Rails.root}/public/phone.xlsx")
phone = File.new("#{Rails.root}/public/phone.txt","w+")
kol_name =  xlsx.column(2)
puts kol_name
kol_name.each do |t|
  mobile = Identity.find_by(name: t)
  number = mobile.kol.mobile_number
  number = mobile.kol.created_at if number.blank?
  phone.write("#{number},")
end
phone.close