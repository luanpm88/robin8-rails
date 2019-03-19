# coding: utf-8
module API
  module V3_0
    class CampaignInvites < Grape::API
      resources :campaign_invites do
        before do
          authenticate!
        end

        params do
          requires :file_name, type: String
        end
        get 'get_uptoken' do
          put_policy = Qiniu::Auth::PutPolicy.new(Rails.application.secrets.qiniu[:bucket], params[:file_name], 3600)

          present :error, 0
          present :file_name, params[:file_name]
          present :uptoken,   Qiniu::Auth.generate_uptoken(put_policy)
        end

        ## 上传截图地址，APP上传返回
        params do
          requires :id,         type: Integer
          requires :screenshot, type: String
        end
        post ':id/upload_screenshot' do
          return error_403!({error: 1, detail: '该账户存在异常,请联系客服!' }) if current_kol.is_forbid?
          
          campaign_invite = current_kol.campaign_invites.find(params[:id])  rescue nil
          campaign        = campaign_invite.campaign                        rescue nil

          return error_403!({error: 1, detail: '该营销活动不存在' }) if campaign_invite.blank?  || campaign.blank?

          campaign_invite.reupload_screenshot(params[:screenshot])
          
          current_kol.generate_invite_task_record

          present :error, 0
          present :campaign_invite, campaign_invite,with: API::V1::Entities::CampaignInviteEntities::Summary, unit_price_rate_for_kol: current_kol.strategy[:unit_price_rate_for_kol]
        end

      end
    end
  end
end