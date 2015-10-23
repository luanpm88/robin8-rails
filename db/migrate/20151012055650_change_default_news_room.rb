class ChangeDefaultNewsRoom < ActiveRecord::Migration
  def change
    NewsRoom.all.each do |room|
      if room.company_name.include? "Default Newsroom"
        company_name = room.company_name.gsub("Default Newsroom", "Default Brand Gallery")
        room.update(:company_name => company_name)
        room.save
      end
    end
  end
end
