require 'rubygems'
require "spreadsheet"
module ImportKols
  class FanstangKols < Base
    Path = '/Users/huxl/fanstang_kols.xls'
    Spreadsheet.client_encoding = "UTF-8"
    def self.import_sheet
      book = Spreadsheet.open Path
      sheet1 = book.worksheet 0
      mcn = get_vs_mcn
      sheet1.each_with_index do |row,index|
        next if index < 1
        kol = create_kol(row)
        create_social_account(kol, row)
        kol.save
        mcn.big_vs << kol
        return if row[1].nil?
      end
    end

    def self.create_kol(row)
      kol = Kol.find_or_initialize_by(:name => row[1])
      kol.desc = row[4]
      kol.kol_role = 'mcn_big_v'
      kol
    end

    def self.create_social_account(kol, row)
      if row[4].present? && SocialAccount.find_by(:provider => 'weibo', :homepage => row[6]).blank?
        social_account = kol.social_accounts.build(:provider => 'weibo', :homepage => row[6], :tag_ids => [get_profession(row[7])])
        social_account.auto_complete_info
      end
    end

    def self.get_vs_mcn
      Kol.find_or_create_by(:name => 'fangstang', :kol_role => 'mcn')
    end
  end
end

# ImportKols::FanstangKols.import_sheet
