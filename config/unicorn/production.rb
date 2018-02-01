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
# ENV['UNICORN_PROCESSES'] ||= '8'
worker_processes 10

# To save some memory and improve performance
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
  # http://ee.riaos.com/?m=201306&paged=12
  # 禁止GC, 配合后续的OOB，来减少请求的执行时间
  # GC.disable

  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end
end
