module SuccessFormatter
  def self.call obj, env
    if obj.is_a? Array and env['api.endpoint'].header
      {
        :items => obj,
        :paginate => env['api.endpoint'].header
      }
    else
      obj
    end.to_json
  end
end

module Brand
  module V1
    class Endpoints < Base
      version 'v1', using: :path
      formatter :json, SuccessFormatter

      # helpers
      #
      helpers APIHelpers

      # representations
      #
      represent Campaign,         with: Entities::Campaign
      represent CampaignInvite,   with: Entities::CampaignInvite
      represent CampaignApply,    with: Entities::CampaignApply
      represent User,             with: Entities::User
      represent Transaction,      with: Entities::Transaction
      represent Invoice,          with: Entities::Invoice
      represent InvoiceReceiver,  with: Entities::InvoiceReceiver
      represent InvoiceHistory,   with: Entities::InvoiceHistory
      # namespaces
      #
      namespace 'user', desc: 'Operations about current user' do
        mount UserAPI
      end

      namespace 'invoice', desc: 'invoice' do
        mount InvoiceAPI
      end

      namespace 'invoice_receiver', desc: 'invoice receiver' do
        mount InvoiceReceiverAPI
      end

      namespace 'util', desc: 'Util' do
        mount UtilAPI
      end

      mount CampaignsAPI
      mount CampaignInvitesApi
      mount CampaignAppliesAPI
      mount AlipayOrdersAPI
      mount TransactionsAPI
      mount InvoiceHistoriesAPI
    end
  end
end
