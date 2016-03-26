# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'jokee'
set :user, 'deploy'
set :repo_url, 'git@github.com:hkthanh89/joke.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/home/#{fetch(:user)}/apps/#{fetch(:application)}"

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml', '.env')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :unicorn_pid, ->{ "#{shared_path}/pids/unicorn.pid" }
set :rails_env, 'production'

namespace :rails do
  desc 'Start application'
  task :start do
    on roles(:web), in: :sequence, wait: 5 do
      within release_path do
        execute :bundle , "exec unicorn_rails -c config/unicorn.rb -D -E #{fetch(:rails_env)}"
      end
    end
  end

  desc 'Restart application'
  task :stop do
    on roles(:web), in: :sequence, wait: 5 do
      execute :kill, "-s QUIT `cat #{fetch(:unicorn_pid)}`"
    end
  end
end

namespace :nginx do
  %w[start stop restart].each do |command|
    desc "#{command} Nginx server"
    task command do
      on roles(:web) do
        execute "sudo service nginx #{command}"
      end
    end
  end
end

namespace :db do
  desc "Run db seed"
  task :seed do
    on roles(:db) do
      within release_path do
        with rails_env: :production do
          execute :rake, "db:seed"
        end
      end
    end
  end
end

namespace :deploy do

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  after 'deploy:finishing', 'rails:stop'
  after 'deploy:finishing', 'rails:start'
end

namespace :setup do
  desc "Symlink config files for Nginx and Unicorn"
  task :symlink_config do
    on roles(:app) do
      execute "rm -f /etc/nginx/sites-enabled/default"
      execute "ln -nfs #{current_path}/config/nginx.conf /etc/nginx/sites-enabled/#{fetch(:application)}"
      execute "ln -nfs #{current_path}/config/unicorn_init.sh /etc/init.d/unicorn_#{fetch(:application)}"
    end
  end
end