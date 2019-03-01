class MarketingDashboard::CreationsController < MarketingDashboard::BaseController
  before_filter :get_creation, except: [:index, :search_kols]

  def index
    @q    = Creation.includes(:user).ransack(params[:q])
    @creations = @q.result.order(updated_at: :desc).paginate(paginate_params)
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
    @tender_kols = @creation.creation_selected_kols.quoted
  end

  def update_auditing
    alert = '无效的操作'
    if @creation.is_pending?
      if params[:status] == 'passed'
        params[:recommend_kols] && params[:recommend_kols].each do |_kol|
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
        @creation.update_attributes(status: 'passed', fee_rate: params[:fee_rate].to_f/100)
      else
        @creation.update_attributes(status: 'unpassed')
        @creation.reject_reason.set(params[:reject_reason])
      end
      alert = Creation::ALERTS[@creation.status]   
    end
    render json: {status: :success, href: marketing_dashboard_creations_path(q: {status_eq: :pending}), alert: alert}
  end

  def search_kols
    if params[:type] == 'weibo'
      res = BigV::Weibo.search(params[:profile_name], params[:page_no])
    else
      res = BigV::PublicWechatAccount.search(params[:profile_name], params[:page_no])
    end

    render json: {data: JSON(res)}
  end

  private

  def get_creation
    @creation = Creation.find params[:id]
  end
end
