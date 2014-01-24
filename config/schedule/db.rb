set :output, "/home/deploy/sites/railsbp.com/production/shared/log/cron_log.log"
job_type :rake, "cd :path && RAILS_ENV=:environment bundle exec rake :task :output"

every 1.day, :at => '2am' do
  command "backup perform -t railsbp_com"
end
