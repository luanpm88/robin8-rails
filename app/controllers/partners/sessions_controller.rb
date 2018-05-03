class Partners::SessionsController < ApplicationController

  layout 'partners'

	def new
  end

  def create
    if $redis.get(params[:name]) == params[:password]
      if @admintag = Admintag.find_by_tag(params[:name].titleize)
        session[:admin_tag] = @admintag.tag
        redirect_to partners_kols_path
      else
        flash[:notice] = '请输入正确的用户名与密码'
        redirect_to partners_sign_in_path
      end
    else
      flash[:notice] = '请输入正确的用户名与密码'
      redirect_to partners_sign_in_path
    end
  end

  def destroy
    session[:admin_tag] = nil

    redirect_to partners_sign_in_path
  end

end