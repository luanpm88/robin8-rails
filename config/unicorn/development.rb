# paths
app_root = File.expand_path("../../..", __FILE__)
working_directory app_root

# pid
pid "#{app_root}/tmp/pids/unicorn.pid"

# listen
listen 8181
listen "/tmp/unicorn-express.socket", backlog: 64

# logging
stderr_path "log/unicorn.stderr.log"
stdout_path "log/unicorn.stdout.log"

# workers
worker_processes 2

# To save some memory and improve performance
preload_app true
GC.respond_to?(:copy_on_write_friendly=) and
  GC.copy_on_write_friendly = true

# Force the bundler gemfile environment variable to
# reference the Сapistrano "current" symlink
before_exec do |_|
  ENV["BUNDLE_GEMFILE"] = File.join(app_root, 'Gemfile')
end

# preload
preload_app true

before_fork do |server, worker|
  # the following is highly recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
  end

  # Before forking, kill the master process that belongs to the .oldbin PID.
  # This enables 0 downtime deploys.
  old_pid = "#{server.config[:pid]}.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      puts "Send 'QUIT' signal to unicorn error!"
    end
  end
end

after_fork do |server, worker|
  GC.disable


  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end
  Rails.logger = ActiveRecord::Base.logger = ActionController::Base.logger = begin
    path = Rails.configuration.paths["log"].first
    f = File.open(path.sub(".log", "-#{worker.nr}.log"), "a")
    f.binmode
    f.sync = true
    logger = ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new(f))
    logger.level = Logger::DEBUG
    logger
  end
end