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
          requires :type, type: String
        end
        post '/' do
          if params[:type] == 'common' && !current_user.common_invoice
            error_unprocessable! "请完善普通增值税发票信息，然后重试"
          elsif params[:type] == 'special' && !current_user.special_invoice
            error_unprocessable! "请完善增值税专用发票信息，然后重试"
          elsif !current_user.invoice_receiver
            error_unprocessable! "请完善发票邮寄地址信息，然后重试"
          elsif current_user.appliable_credits < params[:credits].to_i
            error_unprocessable! "输入金额超出可申请金额"
          end

          if params[:type] == 'common'
            invoice_history_params = current_user.common_invoice.slice(:invoice_type, :title).merge(
                                     current_user.invoice_receiver.slice(:name, :phone_number, :address).merge(
                                     {credits: params[:credits]} ))
          elsif params[:type] == 'special'
            invoice_history_params = current_user.special_invoice.slice(:invoice_type, :title, :taxpayer_id, :company_name, :company_address, :company_mobile, :bank_name, :bank_account).merge(
                                     current_user.invoice_receiver.slice(:name, :phone_number, :address).merge(
                                     {credits: params[:credits]} ))
          end

          @invoice_history = current_user.invoice_histories.build(invoice_history_params)
          if @invoice_history.save
            current_user.decrement!(:appliable_credits, params[:credits].to_i)
            invoice_histories = paginate(Kaminari.paginate_array(current_user.invoice_histories.order('created_at DESC')))
            present invoice_histories
          else
            error_unprocessable! @invoice_history.errors.messages.first.last.first
          end
        end

      end
    end
  end
end
