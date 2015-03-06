json.set! :contacts do
  json.array! @contacts, partial: 'contact', as: :contact
end
