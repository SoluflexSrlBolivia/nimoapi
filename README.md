# nimoapi

Linux server installations:
sudo apt-get install ffmpeg
sudo apt-get install redis-server
sudo apt-get install upstart-sysv
sudo apt-get install upstart


https://github.com/mperham/sidekiq/wiki/Deploying-to-Ubuntu

create log file : /var/log/upstart/workers.log
script for initctl
create file /etc/init/sidekiq.conf
https://github.com/mperham/sidekiq/blob/master/examples/upstart/sidekiq.conf


sidekiq manipulate
# Save this config as /etc/init/sidekiq.conf then manage sidekiq with:
#   sudo start sidekiq index=0
#   sudo stop sidekiq index=0
#   sudo status sidekiq index=0



#Development Configuration
Start:

$ bundle exec sidekiq -d -P tmp/sidekiq.pid -L log/sidekiq.log 
where -d demonize, -P pid file, -L log file.

Stop:

$ bundle exec sidekiqctl stop tmp/sidekiq.pid 0
Sidekiq shut down gracefully.
where 0 is number of seconds to wait until Sidekiq exits.