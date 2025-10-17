#!/bin/bash
# Apache Web Server User Date Script
yum -q -y install httpd mod_ssl
echo "MY Web Server!" > /var/www/html/index.html
systemctl enable --now httpd
