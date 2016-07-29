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
        kol.save
        mcn.big_vs << kol
        return if row[8].nil?
      end
    end

    def self.create_kol(row)
      kol = Kol.find_or_initialize_by(:name => row[8])
      kol.name = row[8]
      kol.kol_role = 'mcn_big_v'
      kol.profession_ids = [get_profession(row[13])]
      kol
    end

    def self.create_social_account(kol, row)
      if row[13].present? && SocialAccount.find_by(:provider => 'public_wechat', :uid => row[9]).blank?
        kol.social_accounts.build(:provider => 'public_wechat', :uid => row[9], :username => row[8],
                                  :followers_count => get_follower_count(row[10]),
                                  :price => row[11].to_i, :second_price => row[12].to_i)
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


