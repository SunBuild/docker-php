#!/bin/bash
log(){
	while read line ; do
		echo "`date '+%D %T'` $line"
	done
}

set -e
logfile=/home/LogFiles/entrypoint.log
test ! -f $logfile && mkdir -p /home/LogFiles && touch $logfile
exec > >(log | tee -ai $logfile)
exec 2>&1

set -x

# set fastcgi_read_timeout to resolve 504 gateway time out
sed -i '/include fastcgi_params;/a\fastcgi_read_timeout 300;' /etc/nginx/sites-enabled/default.conf

if [ ! -d "/home/site/wwwroot/docroot" ]; then
  mkdir -p /home/site/wwwroot/docroot
fi
drush @none dl registry_rebuild-7.x

if [ ! -z "$PORT" ];then
	sed -i -e "s/listen   80/listen   ${PORT}/" /etc/nginx/sites-enabled/default.conf
fi

ssh-keygen -A
/usr/sbin/sshd

/start.sh
