require 'rubygems'
require "spreadsheet"
module ImportKols
  class K1Kols < Base
    Path = '/Users/huxl/k1_kols.xls'
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
      kol.brief = row[7]
      kol.kol_role = 'mcn_big_v'
      kol
    end

    def self.create_social_account(kol, row)
      if row[17].present? && SocialAccount.find_by(:provider => 'weibo', :homepage => row[17]).blank?
        kol.social_accounts.build(:provider => 'weibo', :homepage => row[17], :profession_ids => [get_profession(row[20])])
      end
    end

    def self.get_vs_mcn
      Kol.find_or_create_by(:name => 'k1', :kol_role => 'mcn')
    end
  end
end

# ImportKols::K1Kols.import_sheet
