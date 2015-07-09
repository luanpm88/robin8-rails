class AlertsController < InheritedResources::Base
  before_action :authenticate_user!
  before_action :set_alert, only: [:show, :update]
  
  def show
    respond_to do |format|
      if @alert
        format.json
      else
        raise ActiveRecord::RecordNotFound
      end
    end
  end
  
  def create
    @stream = current_user.streams.find(params[:stream_id])
    @alert = Alert.new(alert_params)
    @alert.stream = @stream
    
    respond_to do |format|
      if @alert.save
        format.json { render :show, status: :created, location: @alert }
      else
        format.json { render json: @alert.errors, status: :unprocessable_entity }
      end
    end
  end
  
  def update
    respond_to do |format|
      if @alert.update(alert_params)
        format.json { render :show, status: :ok, location: @alert }
      else
        format.json { render json: @alert.errors, status: :unprocessable_entity }
      end
    end
  end
  
  private

    def set_alert
      stream = current_user.streams.find(params[:stream_id])
      @alert = stream.alert
    end
    
    def alert_params
      params.require(:alert).permit(:email, :phone, :enabled)
    end
end
