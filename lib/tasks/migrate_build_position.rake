namespace :migrate do
  desc "migrate build#position"
  task :build_position => :environment do
    Repository.all.each do |repository|
      position = 1
      repository.builds.each do |build|
        build.update_attribute(:position, position)
        position += 1
      end
    end
  end
end
