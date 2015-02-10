json.array! @posts do |post|
  json.id post.id
  json.text post.text
  json.scheduled_date post.scheduled_date.strftime("%l:%M %p")
end