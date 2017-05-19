#removes old soft-deleted ( CampaignInvite with ()deleted: true) ) invitations
class RemoveOldInvitationsWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false, :queue => :campaign

  def perform
    CampaignInvite.unscoped.where(deleted: true).where('created_at < ?', DateTime.now - 4.days).delete_all
  end
end
