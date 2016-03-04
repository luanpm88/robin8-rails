class CalInfluenceWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :influence, :retry => 1

  def perform(*args)
    job_type = args[0]
    kol_uuid = args[1]
    identity_id = args[2]
    mobiles = args[3]
    if job_type == 'identity'
      Influence::IdentityInfluence.cal_score(kol_uuid,dentity_id)
    elsif job_type == 'contact'
      Influence::ContactInfluence.cal_score(kol_uuid, mobiles)
    end
  end
end
