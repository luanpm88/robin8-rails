desc "Tasks for syncing staging, qa together with production database"
namespace :db do
  sql = File.join(Dir.pwd, "tmp", "prod.sql")

  task export_prod: :environment do
    db  = Rails.configuration.database_configuration["production"]

    system "rm #{sql}"
    system "rm #{sql[0..-5]}.tar.gz"
    system "mysqldump -u #{db['username']} -h #{db['host']} -p #{db['password']} #{db['database']} > #{sql}"
    system "tar -cvzf #{sql[0..-5]}.tar.gz #{sql}"
  end

  task import_to_staging: :environment do
    db = Rails.configuration.database_configuration["staging"]
    system "mysql -u #{db['username']} -h #{db['host']} -p #{db['password']} -f #{db['database']} < #{sql}"
  end

  task import_to_qa: :environment do
    db = Rails.configuration.database_configuration["qa"]
    system "mysql -u #{db['username']} -h #{db['host']} -p #{db['password']} -f #{db['database']} < #{sql}"
  end
end
