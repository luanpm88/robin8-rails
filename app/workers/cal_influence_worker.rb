class CalInfluenceWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :influence, :retry => 1

  def perform(*args)
    job_type = args[0]
    kol_uuid = args[1]
    identity_id = args[2]
    mobiles = args[2]
    if job_type == 'identity'
      Influence::Identity.cal_score(kol_uuid,identity_id)
    elsif job_type == 'contact'
      Influence::Contact.cal_score(kol_uuid, mobiles)
    end
  end
end
