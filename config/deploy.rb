# config valid for current version and patch releases of Capistrano
lock "~> 3.11.0"

set :application, "foolip"
set :repo_url, "git@github.com:nakamotoo/Foolip.git"
set :branch, 'master'
set :deploy_to, '/home/tomohiroo/pecopeco'
set :linked_files, %w{config/master.key config/secrets.yml config/database.yml public/crawling.json}
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}
set :keep_releases, 5
set :rbenv_ruby, '2.5.1'
set :log_level, :debug
set :repo_tree, 'server'
set :unicorn_pid,    "#{current_path}/tmp/pids/unicorn.pid"
set :unicorn_config, "#{current_path}/config/unicorn/production.rb"
set :default_env, { JAVA_HOME: "/usr/java/jdk1.8.0_181-amd64" }
set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }

after 'deploy:publishing', 'deploy:restart'
namespace :deploy do
  desc 'Run seed'
  task :seed do
    on roles(:app) do
      with rails_env: fetch(:rails_env) do
        within current_path do
          execute :bundle, :exec, :rake, 'db:seed_fu'
        end
      end
    end
  end

  desc 'Start crawling'
  task :crawling do
    on roles(:app) do
      with rails_env: fetch(:rails_env) do
        within current_path do
          execute :bundle, :exec, :rake, 'crawling:get_restaurants'
        end
      end
    end
  end

  task :restart do
    invoke 'unicorn:restart'
  end

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
    end
  end
end
