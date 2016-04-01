# set path to application
app_dir = "/home/deploy/apps/jokee/current"
shared_dir = "/home/deploy/apps/jokee/shared"

working_directory app_dir

# Set unicorn options
worker_processes 2
preload_app true
timeout 30

# Set up socket location
listen "#{shared_dir}/sockets/unicorn.sock", :backlog => 64

# Logging
stderr_path "#{shared_dir}/log/unicorn.stderr.log"
stdout_path "#{shared_dir}/log/unicorn.stdout.log"

# Set master PID location
pid "#{shared_dir}/pids/unicorn.pid"

before_fork do |server, worker|
  # Signal.trap 'TERM' do
  #   puts 'Unicorn master intercepting TERM and sending myself QUIT instead'
  #   Process.kill 'QUIT', Process.pid
  # end

  # the following is highly recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!

  # Before forking, kill the master process that belongs to the .oldbin PID.
  # This enables 0 downtime deploys.
  old_pid = "#{shared_dir}/pids/unicorn.pid.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      
    end
  end

end

after_fork do |server, worker|
  # Signal.trap 'TERM' do
  #   puts 'Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT'
  # end

  # the following is *required* for Rails + "preload_app true"
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end