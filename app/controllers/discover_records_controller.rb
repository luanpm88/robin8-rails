class DiscoverRecordsController < ApplicationController
  def create
    @discover_record = DiscoverRecord.new discover_record_params
    if @discover_record.save
      render json: {status: 'ok'}
    else
      render json: @discover_record.errors.full_messages, status: :unprocessable_entity
    end
  end

  private
  def discover_record_params
    params.require(:discover_record).permit(:discover_id, :kol_id)
  end
end
