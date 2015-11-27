class IdentitiesController < ApplicationController
  def current_categories
    categories = []
    if kol_signed_in?
      @identity = Identity.find params[:id]
      categories = @identity.iptc_categories.map { |c| {:id => c.id, :text => c.label} }
    end
    render :json => categories
  end

  def update
    @idientity = Identity.find params[:id]
    @idientity.attributes = identity_params
    categories = params[:identity][:interests]
    categories = '' if categories == nil
    categories = categories.strip.split(',').map {|s| s.strip}.uniq
    @categories = IptcCategory.unscoped.where :id => categories
    if @idientity.valid?
      @idientity.iptc_categories = @categories
      @idientity.save
      render :json => {:result => "ok"}
    else
      render :json => {:result => "fail", :error_message => @kol.errors.full_messages }
    end
  end

  def show
    @identity = Identity.find params[:id]
    render :json => @identity
  end

  def influence
    base_url = 'http://engine-api.robin8.net/api/v1/kols/'
    @identity = Identity.find params[:id]
    if @identity.provider.eql? 'weibo'
      weibo = @identity.uid
      url = base_url + 'weibo/' + weibo
    elsif @identity.provider.eql? 'wechat_third'
      code = @identity.alias
      if !code
        render :json => {:result => 'fail', :error_message => 'not found'}
      end
      name = @identity.name
      url = URI.encode(base_url + 'wx_public/code/' + code + '/name/' + name)
    else
      render :json => {:result => 'fail', :error_message => 'not found'}
      return
    end
    res = RestClient::Request.execute(method: :get, url: url, timeout: 10)
    case res.code
    when 200
      json_res = JSON.parse res
      if(json_res['return_code'] == 0)
        render :json => json_res
      else
        render :json => {:result => 'fail', :error_message => 'not found'}
      end
    else
      render :json => {:result => 'fail', :error_message => 'something was wrong.'}
    end
  end

  def discover
    base_url = 'http://engine-api.robin8.net/api/v1/articles/page/1'

    p = if params[:labels].eql? 'all'
          ''
        else
          '?labels=' + params[:labels]
        end

    url = base_url + p

    res = RestClient::Request.execute(method: :get, url: url, timeout: 10)
    case res.code
    when 200
      json_res = JSON.parse res
      if json_res['return_code'] == 0

        articles = json_res['articles']
        returns_array = []
        10.times do
          returns_array << articles.delete(articles.sample)
        end

        render :json => returns_array
      else
        render :json => {:result => 'fail', :error_message => 'something was wrong.'}
      end
    else
      render :json => {:result => 'fail', :error_message => 'something was wrong.'}
    end
  end

  def destroy
    @identity = Identity.find params[:id]       rescue nil
    if @identity && @identity.destroy
      render :json => {:result => 'ok', :newest_identities => current_kol.identities }
    else
      render :json => {:result => "fail", :error_message => "not found!"}
    end
  end

  private
  def identity_params
    params.require(:identity).permit(:audience_age_groups, :audience_gender_ratio, :audience_regions,
      :edit_forward, :origin_publish, :forward, :origin_comment, :partake_activity, :panel_discussion,
      :undertake_activity, :undertake_activity, :image_speak, :give_speech, :audience_likes, :audience_friends,
      :audience_talk_groups, :audience_publish_fres, :unionid
    )
  end


end
