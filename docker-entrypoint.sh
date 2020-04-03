#!/bin/sh
echo 'Container Magento2 is starting'
echo 'List of information about main products used:'
php -v
git --version
ssh -V
cat /etc/os-release
uname -a
echo ''
/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
