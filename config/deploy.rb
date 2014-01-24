require 'capistrano_colors'
require 'bundler/capistrano'

require 'rvm/capistrano'
set :rvm_ruby_string, 'ruby-2.0.0-p353@railsbp.com'

set :application, "railsbp.com"
set :repository,  "git@github.com:railsbp/railsbp.com.git"
set :rails_env, "production"
set :deploy_to, "/home/deploy/sites/railsbp.com/production"
set :user, "deploy"
set :use_sudo, false

set :scm, :git

ssh_options[:forward_agent] = true

role :web, "app.railsbp.com"                          # Your HTTP server, Apache/etc
role :app, "app.railsbp.com"                          # This may be the same as your `Web` server
role :db,  "db.railsbp.com", :primary => true # This is where Rails migrations will run

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    migrate
    cleanup
    run "sudo monit restart railsbp.com"
  end
end
