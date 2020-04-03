#!/bin/sh
echo 'Container Magento2 is starting'
echo 'List of information about main products used:'
php -v
git --version
ssh -V
cat /etc/os-release
uname -a
echo ''
git clone https://github.com/magento/magento2.git /var/www/magento2
cd /var/www/magento2
composer install --optimize-autoloader --no-interaction --no-progress

/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
