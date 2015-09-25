class KolsList < ActiveRecord::Base
  has_many :kols_lists_contacts
  belongs_to :user

  private

  def needed_user
    user.is_primary? ? user : user.invited_by
  end

  def import_contacts
    path = attachment.queued_for_write[:original].path

    # detect file encoding
    contents = File.read(path)
    detection = CharlockHolmes::EncodingDetector.detect_all(contents)

    contacts = []

    detection.each do |current|
      begin
        contacts = CSV.read path, encoding: current[:encoding]
        break
      rescue Exception
        next
      end
    end

    self.contacts << contacts.inject([]) do |memo, contact|

      contact.reject! {|c| c.nil?}
      if (contact.size == 3) && !contact[0].strip.blank? &&
        !contact[1].strip.blank? && !contact[2].strip.blank? && validate_email(contact[2].strip)

        new_contact = KolsListsContact.where(email: contact[2].strip).first

        memo << if new_contact.nil?
          KolsListsContact.create(email: contact[2].strip,
            name: contact[0].strip << " " << contact[1].strip)
        else
          new_contact.update(name: contact[0].strip << " " << contact[1].strip)

          new_contact
        end
      end

      memo
    end

    if self.contacts.size == 0
      self.errors.add(:uploaded_file, "must have exactly <strong>four</strong> columns, formatted as <strong>first name, last name, email address</strong>")
      return false
    end
  end

end

