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

service ssh start
sed -i "s/error.log/error_$WEBSITE_ROLE_INSTANCE_ID.log/g" /etc/apache2/apache2.conf 
sed -i "s/access.log/access_$WEBSITE_ROLE_INSTANCE_ID.log/g" /etc/apache2/apache2.conf
sed -i "s/{PORT}/$PORT/g" /etc/apache2/apache2.conf

if [ ! -d "/var/lock/apache2" ]; then
  mkdir -p /var/lock/apache2
fi

if [ ! -d "var/log/apache2" ]; then
  mkdir -p /var/log/apache2
fi

if [ ! -d "/var/run/apache2" ]; then
  mkdir -p /var/run/apache2
fi

if [ ! -d "/home/site/wwwroot/docroot" ]; then
  mkdir -p /home/site/wwwroot/docroot
fi

touch /var/log/apache2/access_$WEBSITE_ROLE_INSTANCE_ID.log

echo "$(date) Container started" >> /var/log/apache2/access_$WEBSITE_ROLE_INSTANCE_ID.log

/usr/sbin/apache2ctl -D FOREGROUND

#Copy drush to docroot
cp /usr/local/bin/drush /home/site/wwwroot/docroot/drush


if [ ! -f "/home/site/wwwroot/docroot/drush" ]; then
  echo "running drush registry build ....."
  php drush @none dl registry_rebuild-7.x
fi
