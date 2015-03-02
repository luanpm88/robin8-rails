class PitchSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :sent, :twitter_pitch, :email_pitch, :summary_length, :email_address
end
