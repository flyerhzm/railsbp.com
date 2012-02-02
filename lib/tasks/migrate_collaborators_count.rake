namespace :migrate do
  task :collaborators_count => :environment do
    Repository.all.each do |repository|
      User.current = repository.owner
      repository.collaborators_count = repository.users.count - 1
      repository.save
    end
  end
end
