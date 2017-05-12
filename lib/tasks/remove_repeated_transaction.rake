namespace :hotfix do
  desc '清除资金流水重复数据'
  task remove_repeated_transaction: :environment do
    # TODO: 在删除transaction时，有可能需要处理那条记录后面发生的记录的金额的变化。
    attr_file = File.join(Rails.root, 'config', 'data_attrs', 'repeat_transactions_attrs.yml')
    repeat_transaction_attrs = File.exists?(attr_file) ? YAML.load(File.read(attr_file)) : {}

    repeat_transaction_attrs.each do |key, value|
      value["campaign_name"].each do |campaign_name|
        campaign_ids = Campaign.where("name LIKE '%#{campaign_name}%'").ids
        transactions = Transaction.where(
          account_id: value['kol_id'], 
          item_id: campaign_ids, 
          item_type: 'Campaign'
        ).group_by {|t| [t.account_id, t.item_id, t.direct]}  # 可能会有相同名字，不同id的活动
        repeat_transactions = transactions.values.map{|arr| arr if arr.count > 1}.compact

        repeat_transactions.each do |trans|
          trans_count = trans.count
          deleted_trans = trans[0..(trans_count - 2)]
          deleted_trans_credits = deleted_trans.map(&:credits).sum
          kol = trans.first.account
          if kol.avail_amount > deleted_trans_credits
            kol.update(
              amount: kol.amount - deleted_trans_credits, 
              historical_income: kol.historical_income - deleted_trans_credits
            )
            deleted_trans.map(&:destroy)
          elsif kol.frozen_amount > deleted_trans_credits
            kol.update(
              amount: kol.amount - deleted_trans_credits,
              frozen_amount: kol.frozen_amount - deleted_trans_credits, 
              historical_income: kol.historical_income - deleted_trans_credits
            )
            withdraw = Withdraw.find(value['withdraw_id'])
            withdraw.update(credits: withdraw.credits - deleted_trans_credits)
            deleted_trans.map(&:destroy)
          else
            puts ".....................kol_id: #{kol.id} 余额不足....................."
          end
        end
      end
    end
  end
end