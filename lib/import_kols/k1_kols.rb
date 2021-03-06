require 'rubygems'
require "spreadsheet"
module ImportKols
  class K1Kols < Base
    if Rails.env.production?
      Path = '/home/deployer/k1_kols.xls'
    else
      Path = '/Users/huxl/k1_kols.xls'
    end
    Spreadsheet.client_encoding = "UTF-8"
    def self.import_sheet
      book = Spreadsheet.open Path
      sheet1 = book.worksheet 0
      mcn = get_vs_mcn
      sheet1.each_with_index do |row,index|
        next if index < 4
        puts "==========index:#{index}===name:#{row[1]}"
        kol = create_kol(row)
        create_social_account(kol, row)
        kol_no_exist = kol.new_record?
        kol.save
        mcn.big_vs << kol  if kol_no_exist
        return if row[1].blank? && row[8].blank?
      end
    end

    def self.create_kol(row)
      kol = Kol.find_or_initialize_by(:name => (row[1] || row[8]))
      kol.desc = row[7]
      kol.kol_role = 'mcn_big_v'
      kol.role_apply_status = 'passed'
      kol
    end

    def self.create_social_account(kol, row)
      if row[17].present? && SocialAccount.find_by(:provider => 'weibo', :homepage => row[17]).blank?
        social_account = kol.social_accounts.build(:provider => 'weibo', :homepage => row[17], :tag_ids => [get_profession(row[20])])
        # social_account.auto_complete_info
      end
      if row[8].present? && SocialAccount.find_by(:provider => 'public_wechat', :uid => row[9]).blank?
        social_account = kol.social_accounts.build(:provider => 'public_wechat', :username => row[8], :uid => row[9],
                                  :followers_count => row[10].to_i, :tag_ids => [get_profession(row[13])])
        # social_account.auto_complete_info
      end
    end

    def self.get_vs_mcn
      Kol.find_or_create_by(:name => 'k1', :kol_role => 'mcn')
    end
  end
end

# ImportKols::K1Kols.import_sheet
