class SyncInfluenceAfterSignUpWorker
  include Sidekiq::Worker

  def perform(kol_id,kol_uuid)
    kol = Kol.find kol_id
    kol.create_info_from_test_influence(kol_uuid)
  end
end
