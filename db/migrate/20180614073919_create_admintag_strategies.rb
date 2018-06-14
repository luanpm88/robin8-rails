class CreateAdmintagStrategies < ActiveRecord::Migration
  def change
    create_table :admintag_strategies do |t|
    	t.float :register_bounty, 					default: 0
    	t.float :invite_bounty, 						default: 2.0
    	t.float :invite_bounty_for_admin, 	default: 0
    	t.float :first_task_bounty, 				default: 0
    	t.float :unit_price_rate_for_kol, 	default: 1.0
    	t.float :unit_price_rate_for_admin, default: 0
    	t.float :master_income_rate, 				default: 0.05

    	t.references :admintag

      t.timestamps null: false
    end
  end
end
