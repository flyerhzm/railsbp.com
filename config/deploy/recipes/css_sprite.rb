before "deploy:assets:precompile", "css_sprite:build"

namespace :css_sprite do
  task :build, :roles => :app do
    run "cd #{release_path}; #{rake} RAILS_ENV=#{rails_env} css_sprite:build"
  end
end
