class KolsListsController < ApplicationController
  before_action :authenticate_user!

  def get_contacts_list
    @kols_lists = current_user.kols_lists.where('kols_lists.kols_count > 0')

    render json: @kols_lists.to_json(:include => [:kols_lists_contacts])
  end

  def create
    contents = File.read(params[:private_kols_file].tempfile)
    detection = CharlockHolmes::EncodingDetector.detect(contents)

    if params[:private_kols_file].tempfile.path[-4..-1] != '.csv'
      raise CSV::MalformedCSVError.new(@l.t('smart_campaign.kol.attach_invalid'))
    end

    @kols = []   
    unless contents.blank?
      parameters = {name: params[:private_kols_file].original_filename}
      @kols = current_user.kols_lists.new(parameters)
      @kols.save!
    end

    contacts = []
    detection.each do |current|
      begin
        contacts = CSV.read params[:private_kols_file].tempfile, encoding: detection[:ruby_encoding]
        break
      rescue Exception
        next
      end
    end

    kols_count = 0

    @kols.kols_lists_contacts << contacts.inject([]) do |memo, contact|
      contact.reject! {|c| c.nil?}
      if (contact.size == 3) && !contact[0].strip.blank? &&
        !contact[1].strip.blank? && validate_email(contact[2].strip)

        new_contact = KolsListsContact.create(email: contact[2].strip,
            name: contact[0].strip << " " << contact[1].strip, kols_list_id: @kols.id)
        kols_count = kols_count + 1

        memo << new_contact
      end

      memo
    end

    @kols.kols_count = kols_count
    @kols.save!

    if @kols.blank?
      raise CSV::MalformedCSVError.new(@l.t('smart_campaign.kol.attach_invalid'))
    end

    render json: @kols

  end

  def validate_email(url)
    unless url =~ /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
      false
    else
      true
    end
  end

  def delete_kols_list
    @kols_list = KolsList.find(params[:id])
    @kols_list.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

end
