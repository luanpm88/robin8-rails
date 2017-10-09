require 'csv'

class MarketingDashboard::ManualRechargesController < MarketingDashboard::BaseController
  def index
    @transactions = Transaction.where({
      account_type: 'User',
      direct: "income",
      subject: ["manual_recharge", "manaual_recharge"]
    })

    @q = @transactions.ransack(params[:q])
    @transactions = @q.result.order('created_at DESC').paginate(paginate_params)

    respond_to do |format|
      format.html
      format.csv {
        csv_string = CSV.generate do |csv|
          csv << ["品牌主ID", "品牌主名称", "流水ID", "充值方式", "充值金额", "创建时间", "品牌主公司", "操作人", "销售人员", "状态", "备注"]
          @transactions.each do |c|
            csv << [c.account.id, c.account.smart_name, c.id, c.subject, c.credits.to_f, c.created_at.strftime("%Y-%m-%d %H:%M:%S"), c.item.receiver_name, c.item.operator, c.account.seller.name, c.item.status, c.item.remark ]
          end
        end
        send_data csv_string, :filename => "手动充值列表##{Time.current.strftime("%Y-%m-%d")}.csv"
      }
    end
  end

  def add_seller
    @transaction = Transaction.find(params[:id])
    if request.get?
      render :add_seller
    else
      @transaction.account.update(seller_id: params[:seller_id])
      redirect_to :back, notice: '添加成功'
    end
  end
end
