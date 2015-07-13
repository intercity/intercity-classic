set :output, "log/cron_log.log"

if environment == "production"
  every 12.hours do
    command "/opt/chef/embedded/bin/backup perform -t intercity_#{environment}"
  end
end

every 5.minutes do
  rake "sidekiq:monitoring"
end
