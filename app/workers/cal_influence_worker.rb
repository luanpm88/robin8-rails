class CalInfluenceWorker
  include Sidekiq::Worker

  def perform()
    Kol.active.each do |kol|
      kol.sync_tmp_identity_from_kol(kol.get_kol_uuid)
      KolInfluenceValue.cal_and_store_score(kol.id, kol.get_kol_uuid, nil, nil, true)
    end
  end
end
