desc "Tasks for syncing staging, qa together with production database only on staging.robin8.net server"
namespace :db do
  sql = "/home/deployer/apps/robin8_staging/shared/tmp/prod.sql"

  task export_prod: :environment do
    if Rails.env.staging?
      db  = Rails.configuration.database_configuration["production"]

      system "rm #{sql}"
      system "rm #{sql[0..-5]}.tar.gz"
      system "mysqldump -u #{db['username']} -h #{db['host']} -p#{db['password']} #{db['database']} --set-gtid-purged=OFF > #{sql}"
      system "tar -cvzf #{sql[0..-5]}.tar.gz #{sql}"
    end
  end

  task import_to_staging: :environment do
    if Rails.env.staging?
      db = Rails.configuration.database_configuration["staging"]
      system "mysql -u #{db['username']} -h #{db['host']} -p#{db['password']} -f #{db['database']} < #{sql}"
    end
  end

  task import_to_qa: :environment do
    if Rails.env.staging?
      db = Rails.configuration.database_configuration["qa"]
      system "mysql -u #{db['username']} -h #{db['host']} -p#{db['password']} -f #{db['database']} < #{sql}"
    end
  end
end
