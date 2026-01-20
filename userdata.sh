#!/bin/bash
dnf update -y
dnf install httpd -y
echo "Hello Terra" > /var/www/html/index.html
systemctl start httpd
systemctl enable httpd
