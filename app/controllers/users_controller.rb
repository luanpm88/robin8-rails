class UsersController < ApplicationController

  def get_current_user
    render json: current_user
  end

  def get_active_subscription
    render json: current_user.active_subscription
  end

  def info
    user = current_user.is_primary? ? current_user : current_user.invited_by
    render json: user, each_serializer: UserSerializer
  end

  def new
    @user = User.new
    render :layout => "website"
  end

  def create
    verify_code = Rails.cache.fetch(user_params[:mobile_number])
    if user_params[:mobile_number] == "robin8.best"
      params[:user][:mobile_number] = (1..9).to_a.sample(8).join
    else
      user_params[:mobile_number].strip!      rescue nil
    end
    @user = User.new(user_params)

    if utm_source = cookies['utm_source']
      @user.utm_source = utm_source
      cookies.delete 'utm_source'
    end

    if verify_code != params["user"]["verify_code"]
      flash.now[:errors] = [@l.t("kols.number_and_code_unmatch")]
    elsif @user.valid?
      @user.save
      sign_in @user
      return redirect_to root_path + "#profile"
    else
      flash.now[:errors] = @user.errors.full_messages
    end
    render :new, :layout=>"website"
  end

  def delete_user
    manageable_users = User.where(invited_by_id: current_user.id)
    @user = manageable_users.find(params[:id])
    if @user.avatar_url
      AmazonDeleteWorker.perform_in(20.seconds, @user.avatar_url)
    end
    @user.destroy
    render json: manageable_users
  end

  def identities
    render json: current_user.identities
  end

  def get_avail_amount
    render json: { avail_amount: current_user.avail_amount }
  end

  def get_identities
    if user_signed_in?
      render json: current_user.all_identities
    elsif kol_signed_in?
      render json: current_kol.all_identities
    else
      render json: []
    end
  end

  def disconnect_social
    someone = current_user
    someone = current_kol if someone.nil?
    @identity = someone.identities.find(params[:id])
    unless @identity.blank?
      @identity.destroy
    end

    render json: someone.all_identities
  end

  def manageable_users
    render json: current_user.manageable_users
  end

  def get_private_kols
    if current_user.kols
      render json: current_user.kols.to_json(:methods => [:active, :categories])
    else
      render json: []
    end
  end

  def import_kol
    if current_user.nil?
      return render json: {:status => "This option is available only for registered brands"}
    end
    if params[:first_name].nil? or params[:last_name].nil? or params[:email].nil?
      return render json: {:status => "First name, Last name and Email fields are required"}
    end
    status = create_private_kol(params)
    render json: {:status => status[0]}
  end

  def import_kols
    contents = File.read(params[:private_kols_file].tempfile)
    detection = CharlockHolmes::EncodingDetector.detect(contents)

    if params[:private_kols_file].tempfile.path[-4..-1] != '.csv'
      raise CSV::MalformedCSVError.new(@l.t('smart_campaign.kol.attach_invalid'))
    end

    kols = []
    added_kols = []
    CSV.foreach(params[:private_kols_file].tempfile.path, encoding: detection[:ruby_encoding]) do |row|
      row.reject! {|c| c.nil?}
      if (row.size == 3) && (!row.any? { |col| col.strip.blank? }) && validate_email(row[2].strip)
        params = {first_name: row[0].strip, last_name: row[1].strip, email: row[2].strip}
        status = create_private_kol(params)
        if status[1]
          added_kols << status[1]
        end
        kols << row
      end
    end

    if kols.size == 0
      raise CSV::MalformedCSVError.new(@l.t('smart_campaign.kol.attach_invalid'))
    end
    if added_kols.length > 0
      render json: added_kols
    else
      render json: status[0]
    end
  end

  def validate_email(url)
    unless url =~ /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
      false
    else
      true
    end
  end

  def avail_amount

    avail = if params[:campaign_id].eql?('no')
              current_user.avail_amount
            else
              campaign = Campaign.find params[:campaign_id]
              current_user.avail_amount + campaign.budget
            end

    if avail.to_f >= params[:amount].to_f
      render :json => {valid: true} and return
    end
    render :json => {valid: false} and return
  end

  def qiniu_uptoken
    put_policy = Qiniu::Auth::PutPolicy.new(
      "robin8",     # 存储空间
    )

    uptoken = Qiniu::Auth.generate_uptoken(put_policy)
    render :json => {uptoken: uptoken}
  end

  def set_avatar_url
    current_user.avatar_url = params[:avatar_url]
    current_user.save
    render json: {:result => "ok"}
  end

  private

  def user_params
    params.require(:user).permit(:first_name,:last_name,:email,:password, :mobile_number)
  end

end
