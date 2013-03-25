before "deploy:assets:precompile", "deploy:update_shared_configs"

namespace :deploy do
  task :update_shared_configs do
    run "ln -nfs #{shared_path}/sockets #{release_path}/tmp/sockets"
    run "ln -nfs #{shared_path}/config/*.yml #{release_path}/config/"
    run "ln -nfs #{shared_path}/config/initializers/secret_token.rb #{release_path}/config/initializers/secret_token.rb"
    run "ln -nfs #{shared_path}/builds #{release_path}/builds"
    run "cd #{release_path}; bundle exec rails_best_practices -g"
  end
end
