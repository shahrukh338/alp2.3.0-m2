FROM alpine:3.8

RUN apk --update --no-cache add openrc \
sudo \
dpkg \
bash  \
vim \
tree \
shadow \
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
php7-sodium \
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
redis \
bind-tools \
openjdk8 \
openssh \
erlang \
mariadb \
mariadb-client \
mariadb-server-utils \
mysql \
mysql-client \
mariadb-common \
composer \
xz &&\

wget https://mirrors.aliyun.com/alpine/v3.11/main/x86_64/redis-5.0.14-r0.apk \
	https://mirrors.aliyun.com/alpine/v3.3/main/x86_64/nginx-initscripts-1.8.0-r0.apk \
	https://mirrors.aliyun.com/alpine/v3.3/main/x86_64/nginx-1.8.1-r2.apk && \
apk add --allow-untrusted redis-5.0.14-r0.apk \
	nginx-initscripts-1.8.0-r0.apk \
	nginx-1.8.1-r2.apk &&\
	
	addgroup mysql mysql &&\

#NGINXSSL
mkdir -p /etc/ssl/certs_2021  /etc/nginx/sites-enabled/  /run/nginx &&\
ln -s /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/default.conf &&\
openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 -subj "/C=IN/ST=Telangana/L=Hyderabad/O=Kensium/CN=alpinehack.com" -keyout /etc/ssl/certs_2021/nginx-selfsigned.key -out /etc/ssl/certs_2021/nginx-selfsigned.crt &&\

#IONCUBE and COMPOSER
wget http://www.voipmonitor.org/ioncube/x86_64/ioncube_loader_lin_7.2.so &&\
mv ioncube_loader_lin_7.2.so /var/www/ &&\

#SSH
mkdir ~/.ssh &&\
adduser magento -D -g 1000 &&\
echo  "magento ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers &&\
#echo 'magento ALL=(ALL:ALL) /usr/sbin/nginx, /usr/bin/php, /usr/bin/mysql, /usr/bin/composer, /usr/sbin/crond' | EDITOR='tee -a' visudo &&\
#echo "magento" | passwd --stdin magento &&\
echo "magento:magento"|chpasswd &&\
ssh-keygen -A &&\
ssh-keygen -t rsa -f ~/.ssh/id_rsa -N '' &&\

#RABBIT
wget https://github.com/rabbitmq/rabbitmq-server/releases/download/v3.7.0/rabbitmq-server-generic-unix-latest-toolchain-3.7.0.tar.xz && tar xvf rabbitmq-server-generic-unix-latest-toolchain-3.7.0.tar.xz &&\


#ELASTIC
wget --no-check-certificate -q -O elasticsearch.tar.gz "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.0.0-linux-x86_64.tar.gz" &&\
tar -xvf elasticsearch.tar.gz -C /usr/share/ &&\
mv /usr/share/elasticsearch-5.0.0 /usr/share/elasticsearch &&\
adduser -D elasticsearch -g 1000 -h /usr/share/elasticsearch &&\
mkdir -p /usr/share/elasticsearch/data /usr/share/elasticsearch/logs /usr/share/elasticsearch/config /usr/share/elasticsearch/config/scripts /usr/share/elasticsearch/plugins &&\
rm -rf /usr/share/elasticsearch/modules/x-pack-ml /redis-5.0.14-r0.apk /nginx-1.8.1-r2.apk /tmp/* /var/cache/apk/* /elasticsearch.tar.gz /rabbitmq-server-generic-unix-latest-toolchain-3.7.0.tar.xz &&\
export ES_JAVA_OPTS="$ES_JAVA_OPTS -Djava.io.tmpdir=/usr/share/elasticsearch/tmp" &&\
chown -R elasticsearch:elasticsearch /usr/share/elasticsearch /usr/lib/jvm &&\
echo -e "export ES_JAVA_HOME=/usr/lib/jvm/java-8-openjdk\nexport JAVA_HOME=/usr/lib/jvm/java-8-openjdk\nexport PATH=$PATH:/rabbitmq_server-3.7.0/sbin/" >> /etc/profile

COPY php.ini /etc/php7/
COPY sshd_config /etc/ssh/
COPY startup.sh /
COPY default.conf /etc/nginx/sites-available/
COPY nginx.conf /etc/nginx/
COPY www.conf /etc/php7/php-fpm.d/
COPY auth.json /root/.composer/
COPY elasticsearch.yml /usr/share/elasticsearch/config/
COPY phpinfo.php /var/www/html/

ENTRYPOINT ["/startup.sh"]

EXPOSE 5672 15672 4369 9200 80 443 6379 8888 6082 3306 9000 22
