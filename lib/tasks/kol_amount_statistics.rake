# encoding: utf-8

namespace :kol_amount_statistic  do
  desc "save kol amount statistic to kol_amount.csv"

  task :export => :environment do
    file_path = File.expand_path("~/kol_amount_statistic/kol_amount.csv")
    CSV.open(file_path, "wb") do |csv|
      csv << ['kol id', '昵称', '电话', '账户总金额', '账户可用', '账户冻结金额', '已消费金额(提现/参加夺宝活动)']
      Kol.includes(:transactions).find_each do |kol|
        if !(kol.transactions.blank? && kol.amount == 0 && kol.avail_amount == 0 && kol.frozen_amount == 0)
          csv << [kol.id, kol.name, kol.mobile_number, kol.amount, kol.avail_amount, kol.frozen_amount, kol.transactions.where(account_type: 'Kol').where(direct: 'payout').where("item_type = ? or item_type =?",  "Withdraw", "LotteryActivityOrder").sum(:credits)]
        end
      end
    end

    puts "\n statistic kol amount is complete."
  end
end
