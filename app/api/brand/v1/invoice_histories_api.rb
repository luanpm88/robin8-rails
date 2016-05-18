module Brand
  module V1
    class InvoiceHistoriesAPI < Base
      include Grape::Kaminari
      before do
        authenticate!
      end

      resource :invoice_histories do
        paginate per_page: 8
        get "/" do
          invoice_histories = paginate(Kaminari.paginate_array(current_user.invoice_histories.order('created_at DESC')))
          present invoice_histories
        end

        desc '可申请发票的总额'
        get '/appliable_credits' do
          appliable_credits = current_user.appliable_credits
          { appliable_credits: appliable_credits }
        end

        paginate per_page: 8
        params do
          requires :credits, type: String
        end
        post '/' do
          if !(current_user.invoice && current_user.invoice_receiver)
            error_unprocessable! "请完善发票信息，然后重试"
          elsif current_user.appliable_credits < params[:credits].to_i
            error_unprocessable! "输入金额超出可申请金额"
          end
          invoice_history_params = current_user.invoice.slice(:invoice_type, :title).merge(
                                   current_user.invoice_receiver.slice(:name, :phone_number, :address).merge(
                                   {credits: params[:credits]} ))
          @invoice_history = current_user.invoice_histories.build(invoice_history_params)
          if @invoice_history.save
            current_user.decrement!(:appliable_credits, params[:credits].to_i)
            invoice_histories = paginate(Kaminari.paginate_array(current_user.invoice_histories.order('created_at DESC')))
            present invoice_histories
          else
            error_unprocessable! "保存失败，请重试"
          end
        end

      end
    end
  end
end
