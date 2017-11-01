# 已弃用
# 已弃用
# 已弃用
# 已弃用
# 已弃用

# require 'roo'
# require 'csv'

# begin
#   xlsx = Roo::Spreadsheet.open("#{Rails.root}/public/geometry.xlsx")
#   weizhuce = File.new("#{Rails.root}/public/weizhuce.txt","w+")
#   yizhuce = File.new("#{Rails.root}/public/yizhuce.txt","w+")
#   zidongzhuce = File.new("#{Rails.root}/public/zidongzhuce.txt","w+")
#   xinxiyouwu = File.new("#{Rails.root}/public/xinxiyouwu.txt","w+")
#   phone = xlsx.column(5)
#   line = []
#   phone.each do |t|
#     kol = Kol.find_by(mobile_number: t)
#     if kol.present?
#       kol.admintags << Admintag.find_or_create_by(tag: 'geometry') if kol.admintags.blank?
#       yizhuce.write("#{t},")
#     else
#       line.push(phone.index t)
#     end
#   end
#   puts "标签打完了哟,开始生成注册信息"
#   line.each do |t|
#     kol = xlsx.row(t.to_i + 1)
#     kol_name = kol[1]
#     if kol_name.present?
#       identity = Identity.find_by(name: kol_name)
#       if identity 
#         if identity.kol_id.blank?
#           # && identity.created_at.strftime("%Y%m").to_i >= 201708
#           # user = Kol.create(mobile_number: kol[4] , name: kol[2])
#           # identity.kol_id = user.id
#           # identity.save
#           puts "#{kol[4]}用户生成完毕"
#           puts "#{kol[4]}绑定信息修改完毕"
#           zidongzhuce.write("#{kol[4]},")
#         else
#           puts "#{kol[4]}绑定信息有误"
#           xinxiyouwu.write("#{kol[4]},")
#         end
#       else
#         weizhuce.write("#{kol[4]},")
#       end
#     else
#       weizhuce.write("#{kol[4]},")
#     end
#   end
#   xinxiyouwu.close
#   zidongzhuce.close
#   yizhuce.close
#   weizhuce.close
#   puts "注册信息生成完成"
# rescue
#   puts "出错,请重试"
# end

