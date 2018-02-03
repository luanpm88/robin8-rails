module API
  module V2_0
    class Contacts < Grape::API
      resource :contacts do
        params do
          requires :contacts, type: String
        end
        post 'kol_contacts' do
          contacts = JSON.parse(params[:contacts])
          contacts = contacts.map { |c| c['mobile']}
          begin
            existing_kols = Kol.where(mobile_number: contacts).pluck(:mobile_number)
            already_invited = current_kol.get_invited_users
            contacts_hash = contacts.map do |contact|
              if existing_kols.include? contact
                {
                  mobile_number: contact,
                  status: 'already_kol'
                }
              elsif already_invited.include? contact
                {
                  mobile_number: contact,
                  status: 'already_invited'
                }
              else
                {
                  mobile_number: contact,
                  status: 'not_invited'
                }
              end
            end
            present :error, 0
            present :kol_users, contacts_hash
          rescue Exception => e
            present :error, 1
            present :error_message, "#{e.class} : #{e.message.to_s}"
          end
        end

        params do
          requires :mobile_number, type: String
        end
        post 'send_invitation' do
          current_kol.invited_users << params[:mobile_number]
          invite_content = Emay::TemplateContent.get_invite_sms(current_kol.try(:name))
          status = SmsMessage.send_to(params[:mobile_number], invite_content)
          RegisteredInvitation.where(mobile_number: params[:mobile_number]).first_or_create(
            inviter_id: current_kol.id, status: "pending" )
          if status
            present :error, 0
          else
            present :error, 1
          end
        end
      end
    end
  end
end
