require 'rubygems'
require "spreadsheet"
module ImportKols
  class Robin8WechatKols < Base
    Path = '/Users/huxl/robin8_wechat.xls'
    Spreadsheet.client_encoding = "UTF-8"

    def self.import_sheet
      book = Spreadsheet.open Path
      sheet1 = book.worksheet 0
      mcn = get_robin8_mcn
      sheet1.each_with_index do |row, index|
        next if index < 4
        kol = create_kol(row)
        create_social_account(kol, row)
        kol_no_exist = kol.new_record?
        kol.save
        mcn.big_vs << kol  if kol_no_exist
        return if row[8].nil?
      end
    end

    def self.create_kol(row)
      kol = Kol.find_or_initialize_by(:name => row[8])
      kol.name = row[8]
      kol.kol_role = 'mcn_big_v'
      kol.role_apply_status = 'passed'
      kol
    end

    def self.create_social_account(kol, row)
      if row[13].present? && SocialAccount.find_by(:provider => 'public_wechat', :uid => row[9]).blank?
        social_account = kol.social_accounts.build(:provider => 'public_wechat', :uid => row[9], :username => row[8],
                                  :followers_count => get_follower_count(row[10]),
                                  :price => row[11].to_i, :second_price => row[12].to_i, :tag_ids => [get_profession(row[13])])
        # social_account.auto_complete_info
      end
    end

    def self.get_robin8_mcn
      Kol.find_or_create_by(:name => 'robin8', :kol_role => 'mcn')
    end

    def self.get_follower_count(num)
      num = num.to_f
      num = num * 10000 if num < 5000
      num
    end
  end
end

# ImportKols::Robin8WechatKols.import_sheet


