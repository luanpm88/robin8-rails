module Users
  class RegistrationsController < Devise::RegistrationsController
    layout 'passport'
    respond_to :html, :json

    def new
      super
    end

    def bind
    end

    def create
      user_params[:mobile_number].strip! rescue nil
      @kol = Kol.new(user_params)

      sms_code = Rails.cache.fetch(user_params[:mobile_number])
      return render json: { error: "短信验证码错误" }, status: :forbidden unless sms_code.present? && sms_code == params["user"]["sms_code"]
      return render json: { error: "无效的手机号或密码" }, status: :bad_request unless @kol.valid?

      if @kol.save
        @identity = Identity.find(params[:identity_code]) if params[:identity_code]
        @identity.update(kol: @kol) if @identity and @identity.kol.blank?

        @user = @kol.find_or_create_brand_user
        set_union_access_token(@kol)
        render json: { msg: "注册绑定成功，正在为您跳转...", ok_url: params[:ok_url].presence || brand_url(subdomain: false) }, status: :ok
      else
        render json: { error: "注册绑定时出错了，请检查您的输入" }, status: :bad_request
      end
    end

    def edit
      @kol = current_kol
      @ok_url = params[:ok_url].presence || brand_url(subdomain: false)

      if @kol.mobile_number.blank?
        @edit_mode = :mobile_number
      elsif @kol.encrypted_password.blank?
        @edit_mode = :password
      else
        redirect_to @ok_url
      end
    end

    def update
      @kol = current_kol
      @ok_url = params[:ok_url].presence || brand_url(subdomain: false)

      if @kol.mobile_number.blank?
        user_params = params.require(:user).permit(:mobile_number)
        sms_code = Rails.cache.fetch(user_params[:mobile_number])
        return render json: { error: "短信验证码错误" }, status: :forbidden unless sms_code.present? && sms_code == params["user"]["sms_code"]
      elsif @kol.encrypted_password.blank?
        user_params = params.require(:user).permit(:password)
      else
        return render json: { msg: "资料完整，正在为您跳转...", ok_url: @ok_url }, status: :ok
      end

      if @kol.update(user_params)
        render json: { msg: "资料更新成功，正在为您跳转...", ok_url: @ok_url }, status: :ok
      else
        render json: { error: "资料更新时出错了，请检查您的输入" }, status: :bad_request
      end
    end

    # def update
    #   self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    #   prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)
    #   @old_avatar = self.resource.avatar_url
    #   @new_avatar = params[:user][:avatar_url]
    #   resource_updated = update_resource(resource, account_update_params)
    #   yield resource if block_given?
    #   if resource_updated
    #     if is_flashing_format?
    #       flash_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ?
    #         :update_needs_confirmation : :updated
    #         set_flash_message :notice, flash_key
    #     end
    #     sign_in resource_name, resource, bypass: true
    #     respond_with resource, location: after_update_path_for(resource)
    #     if @new_avatar!=@old_avatar
    #       AmazonStorageWorker.perform_async("user", self.resource.id, @new_avatar, @old_avatar, :avatar_url)
    #     end
    #   else
    #     clean_up_passwords resource
    #     respond_with resource
    #   end
    # end

    protected

    # def update_resource(resource, params)
    #   if params[:password]=="" && params[:password_confirmation]==""
    #     params.delete(:current_password)
    #     resource.update_without_password(params)
    #   else
    #     resource.update_with_password(params)
    #   end
    # end

    private

    def user_params
      params.require(:user).permit(:name, :password, :mobile_number)
    end
  end
end
