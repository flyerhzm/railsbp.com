namespace :migrate do
  desc "migrate repository#builds_count"
  task :builds_count => :environment do
    Repository.all.each do |repository|
      Repository.reset_counters(repository.id, :builds)
    end
  end
end

