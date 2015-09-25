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
    @user = User.new(user_params)
    if @user.valid?
      @user.save
      sign_in @user
      return redirect_to :pricing if current_user.active_subscription.blank?
      return redirect_to session[:redirect_checkout_url] if session[:redirect_checkout_url].present?
      return redirect_to :root
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

  private

  def user_params
    params.require(:user).permit(:first_name,:last_name,:email,:password)
  end

  def create_private_kol(params)
    kol = Kol.where(email: params[:email]).first
    if kol.nil?
      user = User.where(email: params[:email]).first
      if user
        return ["Brand with this email already exists", false]
      end
      #pass = SecureRandom.hex
      #categories = params[:categories]
      #categories = '' if categories == nil
      #categories = categories.strip.split(',').map {|s| s.strip}.uniq
      #categories = IptcCategory.where :id => categories
      #kol = Kol.new(
       # first_name: params[:first_name],
        #last_name: params[:last_name],
        #email: params[:email],
        #password: pass,
        #password_confirmation: pass,
        #is_public: false,
        #iptc_categories: categories
      #)
      #kol.save!
      #PrivateKol.create(kol_id: kol.id, user_id: current_user.id)
    else
      new_private_kol = PrivateKol.where(kol_id: kol.id, user_id: current_user.id).first
      if new_private_kol.nil?
        #PrivateKol.create(kol_id: kol.id, user_id: current_user.id)
      else
        return ["Influencer with this email already added", params[:email]]
      end
    end
    ["ok", false]
  end

end
