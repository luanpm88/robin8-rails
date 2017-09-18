# -*- coding: UTF-8 -*-
require 'roo'
require 'csv'

xlsx = Roo::Spreadsheet.open("#{Rails.root}/public/geometry.xlsx")
txt = File.open("#{Rails.root}/public/geometry.txt" ,"r").read.split(",")
phone = xlsx.column(5)
CSV.open("#{Rails.root}/public/123.csv" ,"wb") do |csv|
	txt.each do |t|
	  line = phone.index(t.to_i) + 1
	  row = xlsx.row(line)
	  csv << row
	end
end

# xlsx2 = Roo::Spreadsheet.open("#{Rails.root}/public/geometry2.xlsx")
# txt2 = File.open("#{Rails.root}/public/geometry2.txt" ,"r").read.split(",")
# kol_name = xlsx2.column(2)
# CSV.open("#{Rails.root}/public/345.csv" ,"wb") do |csv|
# 	txt2.each do |t|
# 	  line = kol_name.index(t.to_i) + 1
# 	  row = xlsx2.row(line)
# 	  csv << row
# 	end
# end