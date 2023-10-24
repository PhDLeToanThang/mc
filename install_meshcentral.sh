#!/bin/bash
clear
cd ~

############### Tham số cần thay đổi ở đây ###################
echo "FQDN: e.g: demo.company.vn"   # Đổi địa chỉ web thứ nhất Website Master for Resource code - để tạo cùng 1 Source code duy nhất 
read -e FQDN
echo "dbname: e.g: mcdata"   # Tên DBNane
read -e dbname
echo "dbuser: e.g: usermcdata"   # Tên User access DB lmsatcuser
read -e dbuser
echo "Database Password: e.g: P@$$w0rd-1.22"
read -s dbpass
echo "phpmyadmin folder name: e.g: mcdbadmin"   # Đổi tên thư mục phpmyadmin khi add link symbol vào Website 
read -e phpmyadmin
echo "MeshCentral Folder Data: e.g: mcdata"   # Tên Thư mục Data vs Cache
read -e FOLDERDATA
echo "dbtype name: e.g: mysql"   # Tên kiểu Database
read -e dbtype
echo "dbhost name: e.g: localhost"   # Tên Db host connector
read -e dbhost

GitMCversion="1.1.13"

echo "run install? (y/n)"
read -e run
if [ "$run" == n ] ; then
  exit
else


# Cập nhật hệ thống
sudo apt update -y
sudo apt upgrade -y

#Step 1. Cài đặt Nginx
sudo apt-get install nginx -y
#sudo systemctl stop nginx.service 
sudo systemctl start nginx.service 
sudo systemctl enable nginx.service

#Step 2. Cài đặt PHP 8 và các gói liên quan
sudo apt install software-properties-common -y
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update -y
sudo apt install php8.0-fpm php8.0-common php8.0-mbstring php8.0-xmlrpc php8.0-soap php8.0-gd php8.0-xml php8.0-intl php8.0-mysql php8.0-cli php8.0-mcrypt php8.0-ldap php8.0-zip php8.0-curl php8.0-bz2 -y

systemctl restart php8.0-fpm.service

#Step 3. Cài đặt MariaDB
sudo apt install mariadb-server mariadb-client -y
sudo systemctl stop mysql.service 
sudo systemctl start mysql.service 
sudo systemctl enable mysql.service

#Step 4. Cài đặt phpMyAdmin
sudo apt install phpmyadmin -y

#Step 5. # Cấu hình Nginx để chạy MeshCentral
sudo systemctl start nginx
sudo systemctl enable nginx

#Step 6. Cấu hình MariaDB
#Run the following command to secure MariaDB installation.
#sudo mysql_secure_installation

#You will see the following prompts asking to allow/disallow different type of logins. Enter Y as shown.
# Enter current password for root (enter for none): Just press the Enter
# Set root password? [Y/n]: Y
# New password: Enter password
# Re-enter new password: Repeat password
# Remove anonymous users? [Y/n]: Y
# Disallow root login remotely? [Y/n]: N
# Remove test database and access to it? [Y/n]:  Y
# Reload privilege tables now? [Y/n]:  Y
# After you enter response for these questions, your MariaDB installation will be secured.

#Step 7. # Tạo cơ sở dữ liệu cho MeshCentral trong MySQL MariaDB
mysql -uroot -prootpassword -e "CREATE DATABASE $dbname CHARACTER SET utf8 COLLATE utf8_unicode_ci";
mysql -uroot -prootpassword -e "CREATE USER '$dbuser'@'$dbhost' IDENTIFIED BY '$dbpass'";
mysql -uroot -prootpassword -e "GRANT ALL PRIVILEGES ON $dbname.* TO '$dbuser'@'$dbhost'";
mysql -uroot -prootpassword -e "FLUSH PRIVILEGES";
#mysql -uroot -prootpassword -e "SHOW DATABASES";

#Save the file then restart the MariaDB service to apply the changes.
#systemctl restart mariadb

#Step 8. Download và Cài đặt MeshCentral
wget https://github.com/Ylianst/MeshCentral/archive/refs/tags/${GitMCversion}.zip

sudo mkdir /var/www
unzip ${GitMCversion}.zip -d /var/www/
mv /var/www/MeshCentral-${GitMCversion}/ /var/www/$FQDN

sudo chown -R $USER:$USER /var/www/$FQDN
cd /var/www/$FQDN
sudo chmod -R 755 /var/www/$FQDN
sudo chown -R www-data:www-data /var/www/$FQDN/

apt install npm -y

#Step 9: Finish MeshCentral installation
cat > /etc/hosts <<END
127.0.0.1 $FQDN
127.0.0.1 localhost

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
END

rm ${GitMCversion}.zip
# Tạo tệp cấu hình cho MeshCentral
cp config-sample.txt config.txt

# Cấu hình MeshCentral để sử dụng MySQL MariaDB
sed -i 's/#db=meshcentral.db/db=${dbname}/' config.txt
sed -i 's/#dbuser=meshcentral.dbuser/dbuser=${dbuser}/' config.txt
sed -i 's/#dbpassword=meshcentral.dbpassword/dbpassword=${dbpass}/' config.txt

#Step 11. Cấu hình Nginx để chạy MeshCentral
echo 'server {'  >> /etc/nginx/sites-available/$FQDN.conf
echo 'listen 80;'  >> /etc/nginx/sites-available/$FQDN.conf
echo '    listen [::]:80;'  >> /etc/nginx/sites-available/$FQDN.conf
echo '    server_name '${FQDN}';'>> /etc/nginx/sites-available/$FQDN.conf
echo '    location / {'>> /etc/nginx/sites-available/$FQDN.conf
echo '    proxy_pass http://localhost:8080;'>> /etc/nginx/sites-available/$FQDN.conf
echo '    proxy_http_version 1.1;'>> /etc/nginx/sites-available/$FQDN.conf
echo '    proxy_set_header Upgrade \$http_upgrade;'>> /etc/nginx/sites-available/$FQDN.conf
echo '    proxy_connect_timeout   60s;' >> /etc/nginx/sites-available/$FQDN.conf
echo '    proxy_read_timeout   120s;' >> /etc/nginx/sites-available/$FQDN.conf
echo '    proxy_set_header Connection 'upgrade';'>> /etc/nginx/sites-available/$FQDN.conf
echo '    proxy_set_header Host \$host;'>> /etc/nginx/sites-available/$FQDN.conf
echo '    proxy_cache_bypass \$http_upgrade;'>> /etc/nginx/sites-available/$FQDN.conf
echo '    proxy_set_header   Connection keep-alive;' >> /etc/nginx/sites-available/$FQDN.conf
echo '    proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;' >> /etc/nginx/sites-available/$FQDN.conf
echo '    proxy_set_header   X-Forwarded-Proto $scheme;' >> /etc/nginx/sites-available/$FQDN.conf
echo '    }'>> /etc/nginx/sites-available/$FQDN.conf
echo '}'>> /etc/nginx/sites-available/$FQDN.conf

#Save and close the file then verify the Nginx for any syntax error with the following command: 
nginx -t

#Step 12. gỡ bỏ apache:
sudo service apache2 stop
sudo apt-get purge apache2 apache2-utils apache2-bin apache2.2-bin apache2-common apache2.2-common -y

sudo apt-get autoremove -y
whereis apache2
apache2: /etc/apache2 -y
sudo rm -rf /etc/apache2 -y
sudo rm -rf /etc/apache2 -y
sudo rm -rf /usr/sbin/apache2 -y
sudo rm -rf /usr/lib/apache2 -y
sudo rm -rf /etc/apache2 -y
sudo rm -rf /usr/share/apache2 -y
sudo rm -rf /usr/share/man/man8/apache2.8.gz -y

sudo ln -s /usr/share/phpmyadmin /var/www/$FQDN/$phpmyadmin
sudo chown -R root:root /var/lib/phpmyadmin
sudo nginx -t

sudo systemctl restart nginx
systemctl restart php8.0-fpm.service

#Enable the configuration by creating a symlink to sites-enabled directory. 
sudo ln -s /etc/nginx/sites-available/$FQDN.conf /etc/nginx/sites-enabled/$FQDN.conf
sudo systemctl restart nginx

#Step 13. Cài đặt Certbot SSL
#sudo apt install certbot python3-certbot-nginx -y
#sudo certbot --nginx -d $FQDN

# You should test your configuration at:
# https://www.ssllabs.com/ssltest/analyze.html?d=$FQDN
#/etc/letsencrypt/live/$FQDN/fullchain.pem
#   Your key file has been saved at:
#   /etc/letsencrypt/live/$FQDN/privkey.pem
#   Your cert will expire on yyyy-mm-dd. To obtain a new or tweaked
#   version of this certificate in the future, simply run certbot again
#   with the "certonly" option. To non-interactively renew *all* of
#   your certificates, run "certbot renew"

# Khởi động lại Nginx
sudo systemctl restart nginx

fi
