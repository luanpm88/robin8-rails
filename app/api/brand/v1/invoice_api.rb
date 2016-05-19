module Brand
  module V1
    class InvoiceAPI < Base
      before do
        authenticate!
      end

      get "/" do
        @invoice = current_user.invoice
        if @invoice
          present @invoice
        else
          {'no_invoice': true}
        end
      end

      params do
        requires :title, type: String
      end
      post "/" do
        @invoice = current_user.build_invoice(declared(params))
        if @invoice.save
          present @invoice
        else
          error_unprocessable! "保存失败，请重试"
        end
      end

      params do
        requires :title, type: String
      end
      put "/" do
        @invoice = current_user.invoice
        @invoice.update_attributes(title: declared(params)[:title])
        present @invoice
      end
    end
  end
end
