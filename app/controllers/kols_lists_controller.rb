class KolsListsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_kols_list, only: [:show, :edit, :update, :destroy]

  # GET /kols_lists
  # GET /media_lists.json
  def index
    @kols_lists = current_user.kols_lists.all

    respond_to do |format|
      format.json
    end
  end

  # GET /kols_lists/1
  # GET /kols_lists/1.json
  def show
  end

  # POST /kols_lists
  # POST /kols_lists.json
  def create
    contents = File.read(params[:private_kols_file].tempfile)
    detection = CharlockHolmes::EncodingDetector.detect(contents)

    if params[:private_kols_file].tempfile.path[-4..-1] != '.csv'
      raise CSV::MalformedCSVError.new(@l.t('smart_campaign.kol.attach_invalid'))
    end

    kols = []
    added_kols = []
    CSV.foreach(params[:private_kols_file].tempfile.path, encoding: detection[:ruby_encoding]) do |row|
      row.reject! {|c| c.nil?}
      if (row.size == 3) && (!row.any? { |col| col.strip.blank? }) && validate_email(row[2].strip)
        parameters = {name: params[:private_kols_file].original_filename}
        kols = current_user.kols_lists.new(parameters)
        kols.contacts = KolsListsContact.create(email: contact[2].strip,
            name: contact[0].strip << " " << contact[1].strip)
        if status[1]
          added_kols << status[1]
        end
        kols << row
      end
    end

    if kols.size == 0
      raise CSV::MalformedCSVError.new(@l.t('smart_campaign.kol.attach_invalid'))
    end
    if added_kols.length > 0
      render json: added_kols
    else
      render json: status[0]
    end
  end

  def validate_email(url)
    unless url =~ /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
      false
    else
      true
    end
  end

  # DELETE /kols_lists/1
  # DELETE /kols_lists/1.json
  def destroy
    @kols_lists.destroy
    respond_to do |format|
#      format.html { redirect_to kols_lists_url, notice: 'Media list was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

end
