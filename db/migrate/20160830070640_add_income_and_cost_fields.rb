class AddIncomeAndCostFields < ActiveRecord::Migration
  def change
    add_column :kols, :historical_income, :float, default: 0
    add_column :users, :historical_payout, :float, default: 0
    add_column :users, :historical_recharge, :float, default: 0

    user_recharge_errors = []
    User.all.each do |user|
      puts "Updating user recharge: #{user.id} \n"
      unless user.update_column(:historical_recharge, user.total_recharge.to_f)
        user_recharge_errors << user.id
      end
    end unless User.where("historical_recharge > ?", 0).count > 0
    puts "ERROR: #{user_recharge_errors.join(', ')}" unless user_recharge_errors.blank?

    user_errors = []
    User.all.each do |user|
      puts "Updating user payout: #{user.id} \n"
      total_income = user.transactions.where(subject: "campaign", direct: "income").sum(:credits)
      total_payout = user.transactions.where(subject: "campaign", direct: "payout").sum(:credits)
      unless user.update_column(:historical_payout, (total_payout - total_income).to_f)
        user_errors << user.id
      end
    end unless User.where("historical_payout > ?", 0).count > 0
    puts "ERROR: #{user_errors.join(', ')}" unless user_errors.blank?

    kol_errors = []
    Kol.all.each do |kol|
      puts "Updating kol income: #{kol.id} \n"
      unless kol.update_column(:historical_income, kol.total_income.to_f)
        kol_errors << kol.id
      end
    end unless Kol.where("historical_income > ?", 0).count > 0
    puts "ERROR: #{kol_errors.join(', ')}" unless kol_errors.blank?
  end
end
