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
