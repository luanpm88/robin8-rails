user = User.last
if user
  20.times do |t|
    @news_room = NewsRoom.create!(
      user_id: user.id,
      company_name: "Company_#{t}",
      description: 'Donec id elit non mexiti porta gravida at eget metus. Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh, ut fermentum massa justo sit amet risus. Etiam porta sem malesuada magna mollis euismod. Donec sed odio dui.',
      email: 'aaa@aaa_#{t}.aaa',
      room_type: 'Privately Held',
      size: '11-50 employees'
    )
  end
end
