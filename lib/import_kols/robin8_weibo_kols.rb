require 'rubygems'
require "spreadsheet"
module ImportKols
  class Robin8WeiboKols < Base
    Path = '/Users/huxl/robin8_weibo_kols.xls'
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
        return if row[1].nil?
      end
    end

    def self.create_kol(row)
      kol = Kol.find_or_initialize_by(:name => row[1])
      kol.kol_role = 'mcn_big_v'
      kol.profession_ids = [get_profession(row[20])]
      kol
    end

    def self.create_social_account(kol, row)
      if row[16].present? && SocialAccount.find_by(:provider => 'weibo', :homepage => row[16]).blank?
        kol.social_accounts.build(:provider => 'weibo', :homepage => row[16], :price => row[18].to_i,
                                  :repost_price => row[19].to_i, :profession_ids => [get_profession(row[13])])
      end
    end

    def self.get_robin8_mcn
      Kol.find_or_create_by(:name => 'robin8', :kol_role => 'mcn')
    end
  end
end

# ImportKols::Robin8WeiboKols.import_sheet


