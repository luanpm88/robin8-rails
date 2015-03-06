json.extract! @media_list, :id, :name

json.set! :contacts do
  json.array! @media_list.contacts, partial: 'contacts/contact', as: :contact
end
