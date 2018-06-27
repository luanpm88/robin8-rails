class AddInviteFrdIncomeToStatisticsKolIncomes < ActiveRecord::Migration
  def change
    add_column :statistics_kol_incomes, :invite_frd_income, :float
    add_column :statistics_kol_incomes, :invite_frd_count, :integer
  end
end
