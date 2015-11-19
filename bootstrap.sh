#! /usr/bin/env bash

# Inspired from https://gist.github.com/rrosiek/8190550

# Variables
APPLICATION_NAME=$1
DOCUMENT_ROOT_ZEND="/var/www/$APPLICATION_NAME/public"
APPENV=local
DBHOST=localhost
DBNAME=$APPLICATION_NAME
DBUSER=root
DBPASSWD=root

# Setting MySQL root password
echo "mysql-server mysql-server/root_password password $DBPASSWD" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password $DBPASSWD" | debconf-set-selections

# Setting PhpMyAdmin variables (password, etc)
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password $DBPASSWD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password $DBPASSWD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $DBPASSWD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none" | debconf-set-selections

apt-get update
apt-get install -y apache2 git curl build-essential python-software-properties php5-cli php5 php5-intl libapache2-mod-php5 php5-mysql
apt-get install -y -f mysql-server-5.5 phpmyadmin

mysql -uroot -p$DBPASSWD -e "CREATE DATABASE IF NOT EXISTS $DBNAME"
mysql -uroot -p$DBPASSWD -e "grant all privileges on $DBNAME.* to '$DBUSER'@'$DBHOST' identified by '$DBPASSWD'"

echo "
Listen 80
Listen 81
" > /etc/apache2/ports.conf

echo "
<VirtualHost *:81>
    ServerAdmin webmaster@localhost
    DocumentRoot /usr/share/phpmyadmin
    DirectoryIndex index.php
    ErrorLog ${APACHE_LOG_DIR}/phpmyadmin-error.log
    CustomLog ${APACHE_LOG_DIR}/phpmyadmin-access.log combined
</VirtualHost>
" > /etc/apache2/sites-available/phpmyadmin.conf

echo "
<VirtualHost *:80>
    ServerName $APPLICATION_NAME.local
    DocumentRoot $DOCUMENT_ROOT_ZEND
    <Directory $DOCUMENT_ROOT_ZEND>
        DirectoryIndex index.php
        AllowOverride All
        Order allow,deny
        Allow from all
    </Directory>
</VirtualHost>
" > /etc/apache2/sites-available/$APPLICATION_NAME.conf

a2enmod rewrite
a2dissite 000-default
a2ensite phpmyadmin
a2ensite $APPLICATION_NAME
service apache2 restart

cd /var/www/$APPLICATION_NAME

curl -Ss https://getcomposer.org/installer | php
php composer.phar install --no-progress

echo "** [ZEND] Visit http://localhost:8080 in your browser for to view the application **"
echo "** [PHPMYADMIN] Visit http://localhost:8090 in your browser **"