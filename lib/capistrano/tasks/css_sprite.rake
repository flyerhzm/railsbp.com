namespace :css_sprite do
  desc 'build css sprite'
  task :build do
    on roles(:app) do
      within release_path do
        execute :rake, 'css_sprite:build'
      end
    end
  end
end
