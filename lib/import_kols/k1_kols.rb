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
        return if row[1].blank? && row[8].blank?
      end
    end

    def self.create_kol(row)
      kol = Kol.find_or_initialize_by(:name => (row[1] || row[8]))
      kol.desc = row[7]
      kol.kol_role = 'mcn_big_v'
      kol
    end

    def self.create_social_account(kol, row)
      if row[17].present? && SocialAccount.find_by(:provider => 'weibo', :homepage => row[17]).blank?
        kol.social_accounts.build(:provider => 'weibo', :homepage => row[17], :profession_ids => [get_profession(row[20])])
      end
      if row[8].present? && SocialAccount.find_by(:provider => 'public_wechat', :uid => row[9]).blank?
        kol.social_accounts.build(:provider => 'public_wechat', :username => row[8], :uid => row[9],
                                  :followers_count => row[10].to_i, :profession_ids => [get_profession(row[13])])
      end
    end

    def self.get_vs_mcn
      Kol.find_or_create_by(:name => 'k1', :kol_role => 'mcn')
    end
  end
end

# ImportKols::K1Kols.import_sheet
