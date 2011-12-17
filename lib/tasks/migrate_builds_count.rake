namespace :migrate do
  desc "migrate repository#builds_count"
  task :builds_count => :environment do
    Repository.all.each do |repository|
      Respoisotyr.reset_counters(repository.id, :builds_count)
    end
  end
end

