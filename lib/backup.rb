# encoding: utf-8
require 'rubygems'
gem 'backup2qiniu'
require 'backup2qiniu'
##
# Backup Generated: robin8_development
# Once configured, you can run the backup with the following command:
#
# $ backup perform -t robin8_development [-c <path_to_configuration_file>]
#
# For more information about Backup's components, see the documentation at:
# http://backup.github.io/backup
#

Model.new(:robin8_backup_local, 'Save robin8 data to local') do

  ##
  # MySQL [Database]
  #
  database MySQL do |db|
    # To dump all databases, set `db.name = :all` (or leave blank)
    db.name               = "robin8_production"
    db.username           = "root"
    db.password           = "Robin888"
    db.host               = "localhost"
    db.port               = 3306
    #db.socket             = "/tmp/mysql.sock"
    # Note: when using `skip_tables` with the `db.name = :all` option,
    # table names should be prefixed with a database name.
    # e.g. ["db_name.table_to_skip", ...]
    # db.skip_tables        = ["skip", "these", "tables"]
    # db.only_tables        = ["only", "these", "tables"]
    db.additional_options = ["--quick", "--single-transaction", "--default-character-set=utf8mb4"]
  end

  ##
  # Redis [Database]
  #

  database Redis do |db|
    db.mode               = :copy # or :sync
    # Full path to redis dump file for :copy mode.
    db.rdb_path           = "/var/lib/redis/dump.rdb"
    # When :copy mode is used, perform a SAVE before
    #copying the dump file specified by `rdb_path`.
    db.invoke_save        = true
    db.host               = 'localhost'
    db.port               = 6379
    # db.socket             = '/tmp/redis.sock'
    db.password           = '3ddabdcbfd880614701fd14c8f096fd82e92d198346ad1071ae8d175e83c2a23bcb3ef55f3ec72ced1d14fdb7e6dd186996e2bf3d6ace245a5e23194e3becf33'
    db.additional_options = []
  end

  ##
  # Config files [Archive]
  #

  archive :config_files do |archive|
    archive.add '/home/deployer/apps/robin8/shared/config/secrets.yml'
  end

  ##
  # Local (Copy) [Storage]
  #
  store_with Local do |local|
    local.path       = "~/backups/"
    local.keep       = 6
    # local.keep       = Time.now - 2592000 # Remove all backups older than 1 month.
  end

  ##
  # Gzip [Compressor]
  #
  compress_with Gzip

  ##
  # Mail [Notifier]
  #
  # The default delivery method for Mail Notifiers is 'SMTP'.
  # See the documentation for other delivery options.
  #
  notify_by Slack do |slack|
    slack.on_success           = true
    slack.on_warning           = true
    slack.on_failure           = true
    slack.webhook_url = 'https://hooks.slack.com/services/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'
  end

end


Model.new(:robin8_backup_qiniu, 'Save robin8 data to qiniu') do

  ##
  # MySQL [Database]
  #
  database MySQL do |db|
    # To dump all databases, set `db.name = :all` (or leave blank)
    db.name               = "robin8_production"
    db.username           = "root"
    db.password           = "Robin888"
    db.host               = "localhost"
    db.port               = 3306
    # db.socket             = "/tmp/mysql.sock"
    # Note: when using `skip_tables` with the `db.name = :all` option,
    # table names should be prefixed with a database name.
    # e.g. ["db_name.table_to_skip", ...]
    # db.skip_tables        = ["skip", "these", "tables"]
    # db.only_tables        = ["only", "these", "tables"]
    db.additional_options = ["--quick", "--single-transaction", "--default-character-set=utf8mb4"]
  end

  ##
  # Redis [Database]
  #

  database Redis do |db|
    db.mode               = :copy # or :sync
    # Full path to redis dump file for :copy mode.
    db.rdb_path           = "/var/lib/redis/dump.rdb"
    # When :copy mode is used, perform a SAVE before
    #copying the dump file specified by `rdb_path`.
    db.invoke_save        = true
    db.host               = 'localhost'
    db.port               = 6379
    # db.socket             = '/tmp/redis.sock'
    db.password           = '3ddabdcbfd880614701fd14c8f096fd82e92d198346ad1071ae8d175e83c2a23bcb3ef55f3ec72ced1d14fdb7e6dd186996e2bf3d6ace245a5e23194e3becf33'
    db.additional_options = []
  end

  ##
  # Qiniu (Copy) [Storage]
  #
  store_with Qiniu do |q|
    q.keep = 4
    q.access_key = '5bRVzHodaZbSwt6lLpO75opJo-TuSJyRoTlwkAON'       # 从网页拿到的 AK
    q.access_secret = 'RGzmCELncrd_AySF6hht0gElCtC0zxB2tWOjkIi7' # 从网页拿到的 SK
    q.bucket = 'mysql-backup'
    q.path = ''
  end

  archive :config_files do |archive|
    archive.add '/home/deployer/apps/robin8/shared/config/secrets.yml'
  end

  ##
  # Gzip [Compressor]
  #
  compress_with Gzip

  ##
  # Mail [Notifier]
  #
  # The default delivery method for Mail Notifiers is 'SMTP'.
  # See the documentation for other delivery options.
  #
  notify_by Slack do |slack|
    slack.on_success           = true
    slack.on_warning           = true
    slack.on_failure           = true
    slack.webhook_url = 'https://hooks.slack.com/services/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'
  end
end
