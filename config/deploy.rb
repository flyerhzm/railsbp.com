require 'capistrano_colors'
require 'bundler/capistrano'
require "delayed/recipes"

$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require 'rvm/capistrano'
set :rvm_ruby_string, 'ruby-1.9.2-p180@railsbp.com'
set :rvm_type, :user

set :application, "railsbp.com"
set :repository,  "git@github.com:flyerhzm/railsbp.com.git"
set :rails_env, :production
set :deploy_to, "/home/huangzhi/sites/railsbp.com/production"
set :user, "huangzhi"
set :use_sudo, false

set :scm, :git

set :rake, "bundle exec rake"

role :web, "railsbp.com"                          # Your HTTP server, Apache/etc
role :app, "railsbp.com"                          # This may be the same as your `Web` server
role :db,  "railsbp.com", :primary => true # This is where Rails migrations will run
role :delayed_job, 'railsbp.com'
set :delayed_job_server_role, :delayed_job

before "deploy:assets:precompile", "config:init"

before "deploy:restart", "delayed_job:stop"
after  "deploy:restart", "delayed_job:start"

after "deploy:stop",  "delayed_job:stop"
after "deploy:start", "delayed_job:start"

namespace :config do
  task :init do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/github.yml #{release_path}/config/github.yml"
    run "ln -nfs #{shared_path}/config/initializers/stripe.rb #{release_path}/config/initializers/stripe.rb"
    run "ln -nfs #{shared_path}/builds #{release_path}/builds"
  end
end

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    migrate
    cleanup
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end
