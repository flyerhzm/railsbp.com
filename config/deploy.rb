set :stages, %w(staging production)
set :default_stage, "staging"
require 'capistrano/ext/multistage'
require 'capistrano_colors'
require 'bundler/capistrano'
require "delayed/recipes"

require 'rvm/capistrano'
set :rvm_ruby_string, 'ruby-1.9.3-p194@railsbp.com'
set :rvm_type, :user

set :application, "railsbp.com"
set :repository,  "git@github.com:railsbp/railsbp.com.git"
set :rails_env, :production
set :deploy_to, "/home/huangzhi/sites/railsbp.com/production"
set :user, "huangzhi"
set :use_sudo, false

set :scm, :git

set :rake, "bundle exec rake"

role :web, "app.railsbp.com"                          # Your HTTP server, Apache/etc
role :app, "app.railsbp.com"                          # This may be the same as your `Web` server
role :db,  "db.railsbp.com", :primary => true # This is where Rails migrations will run
role :delayed_job, 'db.railsbp.com'
set :delayed_job_server_role, :delayed_job

before "deploy:assets:precompile", "config:init"
before "deploy:assets:precompile", "assets:init"

before "deploy:restart", "delayed_job:stop"
after  "deploy:restart", "delayed_job:start"

after "deploy:stop",  "delayed_job:stop"
after "deploy:start", "delayed_job:start"

namespace :config do
  task :init do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/github.yml #{release_path}/config/github.yml"
    run "ln -nfs #{shared_path}/config/mailers.yml #{release_path}/config/mailers.yml"
    run "ln -nfs #{shared_path}/builds #{release_path}/builds"
    run "cd #{release_path}; bundle exec rails_best_practices -g"
  end
end

namespace :assets do
  task :init, :roles => :app do
    run "cd #{release_path}; #{rake} RAILS_ENV=#{rails_env} css_sprite:build"
  end
end

set :assets_dependencies, %w(app/assets lib/assets vendor/assets Gemfile.lock config/routes.rb)

namespace :deploy do
  namespace :assets do

    desc <<-DESC
      Run the asset precompilation rake task. You can specify the full path \
      to the rake executable by setting the rake variable. You can also \
      specify additional environment variables to pass to rake via the \
      asset_env variable. The defaults are:

        set :rake,      "rake"
        set :rails_env, "production"
        set :asset_env, "RAILS_GROUPS=assets"
        set :assets_dependencies, fetch(:assets_dependencies) + %w(config/locales/js)
    DESC
    task :precompile, :roles => :web, :except => { :no_release => true } do
      from = source.next_revision(current_revision)
      if capture("cd #{latest_release} && #{source.local.log(from)} #{assets_dependencies.join ' '} | wc -l").to_i > 0
        run %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile}
      else
        logger.info "Skipping asset pre-compilation because there were no asset changes"
      end
    end

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
