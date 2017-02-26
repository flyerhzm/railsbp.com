namespace :rails_best_practices do
  desc 'generate config'
  task :generate_config do
    on roles(:app) do
      within release_path do
        execute :rails_best_practices, '-g'
      end
    end
  end
end
