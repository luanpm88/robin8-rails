ActiveAdmin.register Pitch do

  permit_params :user_id , :release_id, :twitter_pitch, :email_pitch, :summary_length,
                :email_address, :email_subject, :email_targets, :twitter_targets

end
