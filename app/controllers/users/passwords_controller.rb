module Users
  class PasswordsController < ApplicationController
    layout 'passport'
    respond_to :html, :json

    def new
    end

    def create
      @kol = Kol.where(mobile_number: user_params[:mobile_number]).first
      return render json: { error: "没找到绑定此手机号的注册用户，请先注册" }, status: :bad_request unless @kol
      return render json: { error: "短信验证码错误" }, status: :forbidden unless YunPian::SendRegisterSms.verify_code(user_params[:mobile_number], params["user"]["sms_code"])

      if @kol.update(password: user_params[:password])
        flash[:notice] = "重置密码成功，请您重新登录"
        render json: { msg: "重置密码成功，正在为您跳转...", ok_url: login_url(params.permit(:ok_url)) }, status: :ok
      else
        render json: { error: "重置密码出错了，请稍后重试" }, status: :bad_request
      end
    end

    # def create
    #   super do
    #     unless self.resource.persisted?
    #       self.resource = Kol.send_reset_password_instructions resource_params
    #       resource_name = :kol
    #     end
    #   end
    # end

    private

    def user_params
      params.require(:user).permit(:password, :mobile_number)
    end
  end
end
