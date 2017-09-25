# -*- coding: UTF-8 -*-
require 'roo'
require 'csv'

# #生成用户表
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

#插入手机号
# xlsx = Roo::Spreadsheet.open("#{Rails.root}/public/phone.xlsx")
# txt = File.open("#{Rails.root}/public/1.txt" ,"r").read.split(",")
# CSV.open("#{Rails.root}/public/123.csv" ,"wb") do |csv|
#   txt.count.times do |t|
#   	row = xlsx.row(t+1).push(txt[t])
#   	csv << row
#   end
# end 

#geometry 活动表
# txt = File.open("#{Rails.root}/public/campaign.txt" ,"r").read.split("&")
# CSV.open("#{Rails.root}/public/campaign.csv" ,"wb") do |csv|
#   txt.each do |t|
# 	csv << t.split("@")
#   end
# end
