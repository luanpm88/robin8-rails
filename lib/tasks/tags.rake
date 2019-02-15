# encoding: utf-8
namespace :tags do

	task :update => :environment do
		ary = %w(airline appliances auto babies beauty books camera ce digital education entertainment finance fitness food furniture games health hotel internet mobile music realestate sports travel fashion)

		Tag.where.not(name: ary).update_all(enabled: false)
	end

end