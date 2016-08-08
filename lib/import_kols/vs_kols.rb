require 'rubygems'
require "spreadsheet"
module ImportKols
  class VsKols < Base
    Path = '/Users/huxl/VS.xls'
    Spreadsheet.client_encoding = "UTF-8"
    def self.import_sheet
      book = Spreadsheet.open Path
      sheet1 = book.worksheet 0
      mcn = get_vs_mcn
      sheet1.each_with_index do |row,index|
        next if index < 4
        kol = create_kol(row)
        create_social_account(kol, row)
        kol.save
        mcn.big_vs << kol
        return if row[1].nil?
      end
    end

    def self.create_kol(row)
      kol = Kol.find_or_initialize_by(:name => row[1])
      kol.app_city = City.where("name like '%#{row[4][-2..-1]}%'").first.name_en  rescue nil
      kol.kol_role = 'mcn_big_v'
      kol.role_apply_status = 'passed'
      if row[2] == "女"
        kol.gender = 2
      elsif row[2] == "男"
        kol.gender = 1
      else
        kol.gender = 0
      end
      kol.desc = row[7]
      kol
    end

    #39、87 没有头像
    def self.set_avatar_url
      book = Spreadsheet.open Path
      sheet1 = book.worksheet 0
      sheet1.each_with_index do |row,index|
        next if index < 4 || index == 39 + 3  ||  index == 87 + 3
        kol = Kol.find_or_initialize_by(:name => row[1])
        kol.avatar_url = "http://7xozqe.com1.z0.glb.clouddn.com/vs_media_#{index - 3}.jpg"
        kol.save
      end
    end

    def self.create_social_account(kol, row)
      if row[13].present? && SocialAccount.find_by(:provider => 'meipai', :homepage => row[13]).blank?
        kol.social_accounts.build(:provider => 'meipai', :homepage => row[13], :price => row[15].to_i, :tag_ids => [get_profession(row[13])])
      end
      if row[16].present? && SocialAccount.find_by(:provider => 'weibo', :homepage => row[16]).blank?
        kol.social_accounts.build(:provider => 'weibo', :homepage => row[16], :tag_ids => [get_profession(row[13])])
      end
    end

    def self.get_vs_mcn
      Kol.find_or_create_by(:name => 'vs_media', :kol_role => 'mcn')
    end
  end
end

# ImportKols::VsKols.import_sheet
