set :output, 'log/cron.log'
env :JAVA_HOME, ENV['JAVA_HOME']
env :PATH, ENV['PATH']
job_type :rbenv_rake, %q!eval "$(rbenv init -)"; cd :path && :environment_variable=:environment bundle exec rake :task --silent :output!

every 1.day, :at => '2:45 am', roles: [:app] do
  rake "crawling:get_restaurants"
end
