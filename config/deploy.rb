set :rvm_type, :user
set :rvm_ruby_version, '2.3.3'

set :application, 'railsbp.com'
set :repo_url, 'git@github.com:railsbp/railsbp.com.git'
set :branch, 'master'
set :deploy_to, '/home/deploy/sites/railsbp.com/production'
set :keep_releases, 5

set :linked_files, %w{config/database.yml config/github.yml config/mailers.yml config/secrets.yml}

set :linked_dirs, %w{bin log builds tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/uploads}

set :rails_env, "production"

set :disallow_pushing, true

namespace :deploy do
  before :compile_assets, "css_sprite:build"
  after :publishing, "rails_bes_practices:generate_config"
end
