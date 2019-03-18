class KolPkController < ApplicationController
  layout false

  def index
    # Shows the list of PK challeges that a KOL has had
    # 显示这KOL 已pk 过的历史
    @kol = Kol.find(params[:id])
    Rails.logger.kol_pk.info "--kol_pk index: #{request.url}"
  end

  def new
    # After weibo login, new KOL comes here
    # 登录微博后来这儿

    @fighting_at = Time.now.to_i
    weibo_uid = current_kol.identities.where(provider: 'weibo').last.uid
    challengee_weibo_uid = Kol.find(params[:challengee_id]).identities.
      where(provider: 'weibo').last.uid

    # 偷偷的开始收集KOL 的weibo influence metric
    # Preliminarily starts the process to get influence score
    # KolInfluenceMetricsWorker.perform_async([weibo_uid, challengee_weibo_uid],[])
    Rails.logger.kol_pk.info "--kol_pk new: #{request.url}"
  end

  def fighting
    # A page for KOL to wait for results
    # 给 KOL 等待PK 结果的地方
    @challenger = Kol.find(params[:challenger_id])
    Rails.logger.kol_pk.info "--kol_pk fighting: #{request.url}"
  end

  def check
    # API to check if the influence metrics are here
    # API 后端来看influence_metrics 好了吗
    challenger         = Kol.find(params[:challenger_id])
    challenger_metrics = challenger.influence_metrics.last

    Rails.logger.kol_pk.info "--kol_pk check: #{request.url}"

    if (challenger_metrics.updated_at.to_i rescue 0) > params[:fighting_at].to_i
      challengee         = Kol.find(params[:challengee_id])
      challengee_metrics = challengee.influence_metrics.last

      industries = challenger_metrics.influence_industries.
        order(industry_score: :desc).limit(3)

      @kol_pk = KolPk.new(challenger_id: params[:challenger_id],
                          challengee_id: params[:challengee_id])
      @kol_pk[:challenger_score] = challenger_metrics.influence_score rescue nil
      @kol_pk[:challengee_score] = challengee_metrics.influence_score rescue nil
      @kol_pk[:first_industry]   = industries[0].industry_name        rescue nil
      @kol_pk[:first_score]      = industries[0].industry_score       rescue nil
      @kol_pk[:second_industry]  = industries[1].industry_name        rescue nil
      @kol_pk[:second_score]     = industries[1].industry_score       rescue nil
      @kol_pk[:third_industry]   = industries[2].industry_name        rescue nil
      @kol_pk[:third_score]      = industries[2].industry_score       rescue nil

      if @kol_pk.save
        render json: {last_pk_at: @kol_pk.created_at.to_i, new_pk_id: @kol_pk.id}
      else
        render json: {status: "error"}
      end
    else
      render json: {last_pk_at: 0}
    end
  end

  def show
    # Shows the current KolPk results
    @kol_pk = KolPk.find(params[:pk_id])
    Rails.logger.kol_pk.info "--kol_pk show: #{request.url}"
  end
end
