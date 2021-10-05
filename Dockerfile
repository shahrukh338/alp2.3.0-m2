FROM alpine:3.14

RUN apk --update --no-cache add openrc \
sudo \
bash  \
vim \
tree \
shadow \
php7 \
php7-bcmath \
php7-cli \
php7-ctype \
php7-curl \
php7-dom \
php7-fpm \
php7-gd \
php7-iconv \
php7-intl \
php7-json \
php7-mbstring \
php7-mcrypt \
php7-openssl \
php7-pdo \
php7-pdo_mysql \
php7-mysqlnd \
php7-pdo_sqlite \
php7-pdo_pgsql \
php7-phar \
php7-session \
php7-simplexml \
php7-soap \
php7-tokenizer \
php7-xml \
php7-xmlwriter \
php7-posix \
php7-xsl \
php7-zip \
php7-zlib \
php7-sockets \
php7-mysqli \
php-sodium \
php7-fileinfo \
netcat-openbsd \
nano \
curl \
nginx \
tini \
su-exec \
util-linux \
coreutils \
git \
gnupg \
ca-certificates \
openssl \
tar \
unzip \
wget \
vim \
redis \
bind-tools \
mysql \
mysql-client \
mariadb-server-utils \
openjdk11 \
openssh \
xz &&\

addgroup mysql mysql &&\

#NGINXSSL
mkdir -p /etc/ssl/certs_2021  /etc/nginx/sites-enabled/  /run/nginx &&\
ln -s /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/default.conf &&\
openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 -subj "/C=IN/ST=Telangana/L=Hyderabad/O=Kensium/CN=alpinehack.com" -keyout /etc/ssl/certs_2021/nginx-selfsigned.key -out /etc/ssl/certs_2021/nginx-selfsigned.crt &&\

#COMPOSER IONCUBE
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" HASH="$(wget -q -O - https://composer.github.io/installer.sig)" php -r "if (hash_file('SHA384', 'composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" &&\
php composer-setup.php --install-dir=/usr/local/bin --filename=composer &&\
wget http://www.voipmonitor.org/ioncube/x86_64/ioncube_loader_lin_7.4.so &&\
mv ioncube_loader_lin_7.4.so /var/www/ &&\

#SSH
mkdir ~/.ssh &&\
adduser magento -D -g 1000 &&\
echo  "magento ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers &&\
echo 'magento ALL=(ALL:ALL) /usr/sbin/nginx, /usr/bin/php, /usr/bin/mysql, /usr/bin/composer, /usr/sbin/crond' | EDITOR='tee -a' visudo &&\
echo "magento:magento" | chpasswd &&\
ssh-keygen -A &&\
ssh-keygen -t rsa -f ~/.ssh/id_rsa -N '' &&\

#RABBIT
echo @testing http://nl.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories &&\
apk add rabbitmq-server@testing &&\
mkdir /etc/rabbitmq &&\
touch /etc/rabbitmq/enabled_plugins &&\
echo "[{rabbit, [{loopback_users, []}]}]." >> /etc/rabbitmq/rabbitmq.config &&\

#ELASTIC
wget --no-check-certificate -q -O elasticsearch.tar.gz "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.0.0.tar.gz" &&\
tar -xvf elasticsearch.tar.gz -C /usr/share/ &&\
mv /usr/share/elasticsearch-6.0.0 /usr/share/elasticsearch &&\
adduser -D elasticsearch -g 1000 -h /usr/share/elasticsearch &&\
mkdir -p /usr/share/elasticsearch/data /usr/share/elasticsearch/logs /usr/share/elasticsearch/config /usr/share/elasticsearch/config/scripts /usr/share/elasticsearch/plugins &&\
export ES_JAVA_OPTS="$ES_JAVA_OPTS -Djava.io.tmpdir=/usr/share/elasticsearch/tmp" &&\
chown -R elasticsearch:elasticsearch /usr/share/elasticsearch /usr/lib/jvm &&\
echo "export JAVA_HOME=/usr/lib/jvm/java-11-openjdk" >> /etc/profile

COPY php.ini /etc/php7/
COPY sshd_config /etc/ssh/
COPY di.xml /
COPY startup.sh /
COPY default.conf /etc/nginx/sites-available/
COPY nginx.conf /etc/nginx/
COPY www.conf /etc/php7/php-fpm.d/
COPY auth.json /root/.composer/
COPY elasticsearch.yml /usr/share/elasticsearch/config/
COPY phpinfo.php /var/www/html/

ENTRYPOINT ["/startup.sh"]

EXPOSE 5672 15672 4369 9200 80 443 6379 8888 6082 3306 9000 22
