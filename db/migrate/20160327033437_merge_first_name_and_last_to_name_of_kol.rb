class MergeFirstNameAndLastToNameOfKol < ActiveRecord::Migration
  def change
    Kol.find_each(:batch_size => 1000).each do |kol|
      if kol.name.blank?
        kol.update(:name => "#{kol.first_name}#{kol.last_name}")
      end
    end
  end
end
