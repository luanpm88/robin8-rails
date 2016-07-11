class QrCodeLoginChannel < ApplicationCable::Channel
  def subscribed
    stream_from "uuid_#{params[:uuid]}"
  end

  def unsubscribed
  end

end
