class AddIncomeAndCostFields < ActiveRecord::Migration
  def change
    add_column :kols, :historical_income, :float, default: 0
    add_column :users, :historical_payout, :float, default: 0
    add_column :users, :historical_recharge, :float, default: 0

    kol_errors = []
    Kol.all.each do |kol|
      puts "Updating kol income: #{kol.id} \n"
      unless kol.update_column(:historical_income, kol.total_income.to_f)
        kol_errors << kol.id
      end
    end

    user_recharge_errors = []
    User.all.each do |user|
      puts "Updating user recharge: #{user.id} \n"
      unless user.update_column(:historical_recharge, user.total_recharge.to_f)
        user_recharge_errors << user.id
      end
    end

    user_errors = []
    User.all.each do |user|
      puts "Updating user payout: #{user.id} \n"
      total_income = user.transactions.where(subject: "campaign", direct: "income").sum(:credits)
      total_payout = user.transactions.where(subject: "campaign", direct: "payout").sum(:credits)
      unless user.update_column(historical_payout: (total_payout - total_income).to_f)
        user_errors << user.id
      end
    end
  end
end
