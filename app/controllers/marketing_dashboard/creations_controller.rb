class MarketingDashboard::CreationsController < MarketingDashboard::BaseController
  before_filter :get_creation, except: [:index]

  def index
    @q    = Creation.ransack(params[:q])
    @creations = @q.result.order(created_at: :desc).paginate(paginate_params)
  end

  def show
  end

  def auditing
    unless @creation.is_pending?
      respond_to do |format|
        format.html { redirect_to :back, alert: Creation::ALERTS[@creation.status] }
      end
    end
  end

  def tenders
    @tender_kols = @creation.creation_selected_kols.is_quoted
  end

  def update_auditing
    if @creation.is_pending?
      if params[:status] = 'passed'
        params[:recommend_kols].each do |_kol|
          CreationSelectedKol.create(
            from_by:        'recommend',
            creation_id:    @creation.id,
            plateform_name: _kol[:plateform_name],
            plateform_uuid: _kol[:plateform_uuid],
            name:           _kol[:name],
            avatar_url:     _kol[:avatar_url],
            desc:           _kol[:desc],
            kol_id:         _kol[:kol_id]
          )
        end
        @creation.update_attributes(status: 'passed', fee_rate: params[:fee_rate])
      else
        @creation.update_attributes(status: 'unpassed')
      end
    end

    @creation.reload

    respond_to do |format|
      format.html { redirect_to :back, alert: Creation::ALERTS[@creation.status] }
    end
  end

  def pass
    if @creation.is_pending? 
      @creation.update(status: 'passed')
      flash[:alert] = "审核通过"
    else
      flash[:alert] = "该活动不是待审核状态，不能审核通过"
    end
    redirect_to  marketing_dashboard_creations_path
  end

  private

  def get_creation
    @creation = Creation.find params[:id]
  end
end
