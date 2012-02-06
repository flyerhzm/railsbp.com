namespace :migrate do
  task :last_build_at => :environment do
    Repository.all.each do |repository|
      if repository.builds.present?
        repository.last_build_at = repository.builds.last.updated_at
      else
        repository.last_build_at = repository.updated_at
      end
      User.current = repository.owner
      repository.save
    end
  end
end
