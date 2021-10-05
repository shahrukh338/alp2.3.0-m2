#!/bin/sh
#nginx
nginx -g 'daemon off;' &
#php
php-fpm7 -F &
#rabbitmq
rabbitmq-plugins enable --offline rabbitmq_management
rabbitmq-server &
#elasticsearch
su - elasticsearch -c /usr/share/elasticsearch/bin/elasticsearch &
#redis
redis-server --daemonize yes
#mysql
if [ ! -d "/run/mysqld" ]; then
   mkdir -p /run/mysqld
   chown -R mysql:mysql /run/mysqld
fi
   chown -R mysql:mysql /var/lib/mysql
   echo 'Initializing database'
   mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql > /dev/null
   tfile=`mktemp`
   if [ ! -f "$tfile" ]; then
   return 1
   fi
# save sql
   echo "[i] Create temp file: $tfile"
   cat << EOF > $tfile
USE mysql;
FLUSH PRIVILEGES;
DELETE FROM mysql.user;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION;
EOF
   echo "[i] Creating database: magento"
   echo "CREATE DATABASE IF NOT EXISTS magento CHARACTER SET utf8 COLLATE utf8_general_ci;" >> $tfile
   echo "GRANT ALL ON magento.* to 'magento'@'%' IDENTIFIED BY 'magento';" >> $tfile
   echo 'FLUSH PRIVILEGES;' >> $tfile
   echo 'SET GLOBAL log_bin_trust_function_creators = 1;' >> $tfile
   echo "[i] run tempfile: $tfile"
   /usr/bin/mysqld --user=mysql --bootstrap --verbose=0 < $tfile
   rm -f $tfile
echo "[i] Sleeping 5 sec"
sleep 5
echo "Starting all process"
exec /usr/bin/mysqld --user=mysql --console --log-bin-trust-function-creators=1 &
#MAGENTO_SSH  
composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition=2.4.2 /var/www/html/magento
mv /di.xml /var/www/html/magento/app/etc/
cd /var/www/html/magento
php bin/magento setup:install --base-url=http://alpinehack.com --db-host=localhost --db-name=magento --db-user=magento --db-password=magento --admin-firstname=admin --admin-lastname=admin --admin-email=praneethpathange@gmail.com --admin-user=shannu --admin-password=kspl@1234 --language=en_US --currency=GBP --timezone=Europe/London --use-rewrites=1
rm -rf generated/code
php bin/magento se:up
php bin/magento c:c
php bin/magento c:f
php bin/magento setup:di:compile
php bin/magento setup:static-content:deploy -f
php bin/magento c:c
php bin/magento c:f

find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} + && find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} + && chown -R :www-data . && chmod u+x bin/magento && chmod -R 777 var generated
rm -rf /tmp/* /var/cache/apk/* /elasticsearch.tar.gz
hostname -i
curl -sS localhost:9200 | grep 'elasticsearch\|number'; echo;
redis-cli --version
php -v
mysql -V
php bin/magento --version
php bin/magento c:c
php bin/magento c:f
/usr/sbin/sshd -D -e -f /etc/ssh/sshd_config
