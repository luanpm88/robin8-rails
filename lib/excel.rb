# -*- coding: UTF-8 -*-
require 'roo'
require 'csv'

xlsx = Roo::Spreadsheet.open("#{Rails.root}/public/geometry.xlsx")
txt = File.open("#{Rails.root}/public/1.txt" ,"r").read.split(",")
puts txt.count
phone = xlsx.column(5)
CSV.open("#{Rails.root}/public/123.csv" ,"wb") do |csv|
	txt.each do |t|
	  line = phone.index(t.to_i)
	  row = xlsx.row(line.to_i + 1)
	  csv << row
	end
end

# xlsx = Roo::Spreadsheet.open("#{Rails.root}/public/geometry.xlsx")
# txt = File.open("#{Rails.root}/public/geometry.txt" ,"r").read.split(",")
# txt2 = File.new("#{Rails.root}/public/geometry2.txt","w+")
# phone = xlsx.column(5)
# phone.each do |t|
#  number = txt.index(t)
#  txt2.write("#{t},") unless number 	
# end
# txt2.close


# CSV.open("#{Rails.root}/public/123.csv" ,"wb") do |csv|
# 	txt.each do |t|
# 	  line = phone.index(t.to_i)
# 	  row = xlsx.row(line.to_i + 1)
# 	  csv << row
# 	end
# end
# xlsx2 = Roo::Spreadsheet.open("#{Rails.root}/public/geometry.xlsx")
# txt2 = File.open("#{Rails.root}/public/456.txt" ,"r").read.split(",")
# puts txt2.count
# kol_name = xlsx2.column(2)
# CSV.open("#{Rails.root}/public/345.csv" ,"wb") do |csv|
# 	txt2.each do |t|
# 	  line = kol_name.index(t)
# 	  row = xlsx2.row(line.to_i + 1)
# 	  csv << row
# 	end
# end
# xlsx3 = Roo::Spreadsheet.open("#{Rails.root}/public/geometry3.xlsx")
# xlsx4 = Roo::Spreadsheet.open("#{Rails.root}/public/geometry4.xlsx")
# txt = File.new("#{Rails.root}/public/geometry.txt","w+")
# name1 = xlsx3.column(5)
# name2 = xlsx4.column(5)
# name1.each do |t|
#   txt.write("#{t},") unless name2.index(t)
# end
# txt.close
# result = name1 | name2
# result.each do |t|
# 	txt.write("#{t},")
# end
# txt.close

