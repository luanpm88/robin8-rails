# -*- coding: UTF-8 -*-
require 'roo'
require 'csv'

xlsx = Roo::Spreadsheet.open("#{Rails.root}/public/geometry.xlsx")
txt = File.open("#{Rails.root}/public/123.txt" ,"r").read.split(",")
 a = 0
 phone = xlsx.column(5)
CSV.open("#{Rails.root}/public/123.csv" ,"wb") do |csv|
	txt.each do |t|
	  line = phone.index(t.to_i) + 1
	  row = xlsx.row(line)
	  csv << row
	end
end
