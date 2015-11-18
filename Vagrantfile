# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = '2'
APPLICATION_NAME = "mywebapp"

@script = <<SCRIPT

# Variables
#APPLICATION_NAME=mywebapp
DOCUMENT_ROOT_ZEND="/var/www/$APPLICATION_NAME/public"
APPENV=local
DBHOST=localhost
DBNAME=$APPLICATION_NAME
DBROOTPASSWD=root
DBUSER=user
DBPASSWD=user

# Setting MySQL root password
debconf-set-selections <<< "mysql-server mysql-server/root_password password $DBROOTPASSWD"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $DBROOTPASSWD"

# Setting PhpMyAdmin variables (password, etc)
debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $DBROOTPASSWD"
debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $DBROOTPASSWD"
debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $DBROOTPASSWD"
debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none"

apt-get update
apt-get install -y apache2 git curl build-essential python-software-properties php5-cli php5 php5-intl libapache2-mod-php5 php5-mysql
apt-get install -y -f mysql-server-5.5 mysql-server phpmyadmin
# > /dev/null 2>&1

mysql -uroot -p$DBROOTPASSWD -e "CREATE DATABASE $DBNAME"
mysql -uroot -p$DBROOTPASSWD -e "grant all privileges on $DBNAME.* to '$DBUSER'@'$DBHOST' identified by '$DBPASSWD'"

echo "
\n\nListen 81\n
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
a2enconf phpmyadmin
a2ensite $APPLICATION_NAME
service apache2 restart

cd /var/www/$APPLICATION_NAME

curl -Ss https://getcomposer.org/installer | php
php composer.phar install --no-progress

echo "** [ZEND] Visit http://localhost:8085 in your browser for to view the application **"
SCRIPT

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = 'ubuntu/trusty64'
  config.vm.network "forwarded_port", guest: 80, host: 8085
  config.vm.hostname = "hostname.local"
  config.vm.synced_folder ".", "/var/www/" + APPLICATION_NAME
  config.vm.provision 'shell', inline: @script

  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--memory", "1024"]
  end

end
