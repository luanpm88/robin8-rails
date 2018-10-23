require 'rubygems'
require "spreadsheet"
module ImportKols
  class PartnerKols < Base
    if Rails.env.production?  || Rails.env.staging? || Rails.env.qa?
      Path = '/home/deployer/partner_cellphone.xls'
    else
      Path = '/Users/huxl/partner_cellphone.xls'
    end
    Spreadsheet.client_encoding = "UTF-8"
    def self.import_sheet
      book = Spreadsheet.open Path
      sheet1 = book.worksheet 0
      sheet1.each_with_index do |row,index|
        next if index < 1
        puts "==========index:#{index}===name:#{row[1]}"
        kol = create_kol(row)
        create_social_account(kol, row)
        kol.save
        return if row[0].nil?
      end
    end

    def self.create_kol(row)
      if row[15].present?
        kol = Kol.find_or_initialize_by(:mobile_number => row[15].to_i.to_s )
      else
        kol = Kol.new
      end
      kol.name = row[0]   if kol.name.blank?
      kol.app_city = City.where("name like '%#{row[1]}%'").first.name_en  rescue nil       if kol.app_city.blank?
      kol.kol_role = 'big_v'
      kol.role_apply_status = 'passed'
      kol.job_info = row[2]
      kol.avatar_url = "http://img.robin8.net/partner_#{row[3].to_i}.png"   if row[3].present?  &&  kol.avatar_url.blank?
      kol.desc = row[4]                                                                     if kol.desc.blank?
      tag_labels = row[5].split(/[,,、\s]/).compact   rescue []
      kol.tags = Tag.where(:label => tag_labels) if tag_labels.size > 0
      kol
    end

    def self.create_social_account(kol, row)
      if row[6].present? && kol.social_accounts.find_by(:provider => 'public_wechat', :uid => row[6]).blank?
        social_account = kol.social_accounts.build(:provider => 'public_wechat', :uid => row[6], :price => row[12].to_i, :followers_count => row[9].to_i)
      end
      if row[7].present? && kol.social_accounts.find_by(:provider => 'wechat', :username => row[7]).blank?
        social_account = kol.social_accounts.build(:provider => 'wechat', :username => row[7], :price => row[13], :followers_count => row[10].to_i)
      end
      if row[8].present? && kol.social_accounts.find_by(:provider => 'weibo', :homepage => row[8]).blank?
        social_account = kol.social_accounts.build(:provider => 'weibo', :homepage => row[8], :price => row[14].to_i)
        # social_account.auto_complete_info
      end
      if row[6].blank? && row[7].blank? && row[8].blank?
        social_account = kol.social_accounts.build(:provider => 'wechat', :username => row[0])
      end
    end

    def self.get_mobile_numbers
      book = Spreadsheet.open Path
      sheet1 = book.worksheet 0
      phones = []
      sheet1.each_with_index do |row,index|
        next if index < 1
        phones << row[15].to_s.to_i if row[15].present?
        return if row[0].nil?
      end
      puts phones.join(",")
    end
  end
end

# ImportKols::PartnerKols.import_sheet
