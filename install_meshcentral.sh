#!/bin/bash
clear
cd ~

############### Tham số cần thay đổi ở đây ###################
echo "FQDN: e.g: demo.company.vn"   # Đổi địa chỉ web thứ nhất Website Master for Resource code - để tạo cùng 1 Source code duy nhất 
read -e FQDN
echo "dbname: e.g: itildata"   # Tên DBNane
read -e dbname
echo "dbuser: e.g: userdata"   # Tên User access DB lmsatcuser
read -e dbuser
echo "Database Password: e.g: P@$$w0rd-1.22"
read -s dbpass
echo "phpmyadmin folder name: e.g: phpmyadmin"   # Đổi tên thư mục phpmyadmin khi add link symbol vào Website 
read -e phpmyadmin
echo "ITIL Folder Data: e.g: itildata"   # Tên Thư mục Data vs Cache
read -e FOLDERDATA
echo "dbtype name: e.g: mariadb"   # Tên kiểu Database
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
sudo apt update
sudo apt upgrade -y

#Step 1. Cài đặt Nginx
sudo apt-get install nginx -y
#sudo systemctl stop nginx.service 
sudo systemctl start nginx.service 
sudo systemctl enable nginx.service

#Step 2. Cài đặt PHP 8 và các gói liên quan
sudo apt install software-properties-common -y
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update
sudo apt install php8.0-fpm php8.0-common php8.0-mbstring php8.0-xmlrpc php8.0-soap php8.0-gd php8.0-xml php8.0-intl php8.0-mysql php8.0-cli php8.0-mcrypt php8.0-ldap php8.0-zip php8.0-curl php8.0-bz2 -y

#Step 3. Cấu hình php.ini
#Open PHP-FPM config file.
#sudo nano /etc/php/8.0/fpm/php.ini
#Add/Update the values as shown. You may change it as per your requirement.
# if new php.ini configure then clear sign sharp # comment
cat > /etc/php/8.0/fpm/php.ini <<END
[PHP]
engine = On
short_open_tag = Off
precision = 14
output_buffering = 4096
zlib.output_compression = Off
implicit_flush = Off
unserialize_callback_func =
serialize_precision = -1
disable_functions = 
disable_classes =
zend.enable_gc = On
zend.exception_ignore_args = On
zend.exception_string_param_max_len = 0
expose_php = Off
file_uploads = On 
allow_url_fopen = On 
memory_limit = 1200M 
upload_max_filesize = 4096M
max_execution_time = 360 
cgi.fix_pathinfo = 0 
date.timezone = asia/ho_chi_minh
max_input_time = 60
max_input_nesting_level = 64
max_input_vars = 5000
post_max_size = 4096M
error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT
display_errors = Off
display_startup_errors = Off
log_errors = On
ignore_repeated_errors = Off
ignore_repeated_source = Off
report_memleaks = On
variables_order = "GPCS"
request_order = "GP"
register_argc_argv = Off
auto_globals_jit = On
auto_prepend_file =
auto_append_file =
default_mimetype = "text/html"
default_charset = "UTF-8"
doc_root =
user_dir =
enable_dl = Off
allow_url_fopen = On
allow_url_include = Off
default_socket_timeout = 60
extension=bz2
extension=curl
;extension=ffi
;extension=ftp
extension=fileinfo
;extension=gd
;extension=gettext
;extension=gmp
extension=intl
;extension=imap
;extension=ldap
extension=mbstring
;extension=exif      ; Must be after mbstring as it depends on it
;extension=mysqli
;extension=oci8_12c  ; Use with Oracle Database 12c Instant Client
;extension=oci8_19  ; Use with Oracle Database 19 Instant Client
;extension=odbc
extension=openssl
;extension=pdo_firebird
;extension=pdo_mysql
;extension=pdo_oci
;extension=pdo_odbc
;extension=pdo_pgsql
;extension=pdo_sqlite
;extension=pgsql
;extension=shmop
;extension=snmp
;extension=soap
;extension=sockets
;extension=sodium
;extension=sqlite3
;extension=tidy
;extension=xsl
;zend_extension=opcache
[CLI Server]
cli_server.color = On

[Date]
;date.timezone =

; https://php.net/date.default-latitude
;date.default_latitude = 31.7667

; https://php.net/date.default-longitude
;date.default_longitude = 35.2333


[filter]

[iconv]

[imap]

[intl]

[sqlite3]

[Pcre]

[Pdo]

[Pdo_mysql]
pdo_mysql.default_socket=

[Phar]

[mail function]
SMTP = localhost
; https://php.net/smtp-port
smtp_port = 25
;sendmail_from = me@example.com
;sendmail_path =
;mail.force_extra_parameters =
mail.add_x_header = Off
;mail.log = syslog

[ODBC]
odbc.allow_persistent = On
odbc.check_persistent = On
odbc.max_persistent = -1
odbc.max_links = -1
odbc.defaultlrl = 4096
odbc.defaultbinmode = 1

[MySQLi]
mysqli.max_persistent = -1
mysqli.allow_persistent = On
mysqli.max_links = -1
mysqli.default_port = 3306
mysqli.default_socket =
mysqli.default_host =
mysqli.default_user =
mysqli.default_pw =
mysqli.reconnect = Off

[mysqlnd]
mysqlnd.collect_statistics = On
mysqlnd.collect_memory_statistics = Off

[OCI8]

[PostgreSQL]
pgsql.allow_persistent = On
pgsql.auto_reset_persistent = Off
pgsql.max_persistent = -1
pgsql.max_links = -1
pgsql.ignore_notice = 0
pgsql.log_notice = 0

[bcmath]
bcmath.scale = 0

[browscap]

[Session]
session.save_handler = files
session.use_strict_mode = 0
session.use_cookies = 1
session.use_only_cookies = 1
session.name = PHPSESSID
session.auto_start = 0
session.cookie_lifetime = 0
session.cookie_path = /
session.cookie_domain =
session.cookie_httponly = on
session.cookie_samesite =
session.serialize_handler = php
session.gc_probability = 0
session.gc_divisor = 1000
session.gc_maxlifetime = 1440
session.referer_check =
session.cache_limiter = nocache
session.cache_expire = 180
session.use_trans_sid = 0
session.sid_length = 26
session.trans_sid_tags = "a=href,area=href,frame=src,form="
session.sid_bits_per_character = 5

[Assertion]
zend.assertions = -1

[COM]

[mbstring]

[gd]

[exif]

[Tidy]
tidy.clean_output = Off

[soap]
soap.wsdl_cache_enabled=1
soap.wsdl_cache_dir="/tmp"
soap.wsdl_cache_ttl=86400
soap.wsdl_cache_limit = 5

[sysvshm]

[ldap]
ldap.max_links = -1

[dba]

[opcache]

[curl]

[openssl]

[ffi]
END

systemctl restart php8.0-fpm.service

#Step 4. Cài đặt MariaDB
sudo apt install mariadb-server mariadb-client -y
sudo systemctl stop mysql.service 
sudo systemctl start mysql.service 
sudo systemctl enable mysql.service

#Step 5. Cài đặt phpMyAdmin
sudo apt install phpmyadmin -y

#Step 6. # Cấu hình Nginx để chạy MeshCentral
sudo systemctl start nginx
sudo systemctl enable nginx
sudo mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak
sudo cp meshcentral/nginx.conf /etc/nginx/sites-available/default

#Step 7. Cấu hình MariaDB
#Run the following command to secure MariaDB installation.
sudo mysql_secure_installation

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

#Step 8. # Tạo cơ sở dữ liệu cho MeshCentral trong MySQL MariaDB
sudo mysql -uroot -prootpassword -e "CREATE DATABASE $dbname CHARACTER SET utf8 COLLATE utf8_unicode_ci";
sudo mysql -uroot -prootpassword -e "CREATE USER '$dbuser'@'$dbhost' IDENTIFIED BY '$dbpass'";
sudo mysql -uroot -prootpassword -e "GRANT ALL PRIVILEGES ON $dbname.* TO '$dbuser'@'$dbhost'";
sudo mysql -uroot -prootpassword -e "FLUSH PRIVILEGES";
sudo mysql -uroot -prootpassword -e "SHOW DATABASES";

# Nếu đã có thì bỏ qua đoạn hàm này như thế nào ?
#Step 9. Next, edit the MariaDB default configuration file and define the innodb_file_format:
#nano /etc/mysql/mariadb.conf.d/50-server.cnf
#Add the following lines inside the [mysqld] section: 
# if new php.ini configure then clear sign sharp # comment
#cat > /etc/mysql/mariadb.conf.d/50-server.cnf <<END
#[mysqld]
#innodb_file_format = Barracuda
#innodb_file_per_table = 1
#innodb_large_prefix = ON
#END

#Save the file then restart the MariaDB service to apply the changes.
systemctl restart mariadb

#Step 10. Download và Cài đặt MeshCentral
sudo mkdir /opt/$FQDN
sudo chown $USER:$USER /opt/$FQDN
cd /opt/$FQDN
wget https://github.com/Ylianst/MeshCentral/archive/refs/tags/${GitMCversion}.zip
unzip MeshCentral-${GitMCversion}.zip
npm install

# Tạo tệp cấu hình cho MeshCentral
cp config-sample.txt config.txt

# Cấu hình MeshCentral để sử dụng MySQL MariaDB
sed -i 's/#db=meshcentral.db/db=${dbname}/' config.txt
sed -i 's/#dbuser=meshcentral.dbuser/dbuser=${dbuser}/' config.txt
sed -i 's/#dbpassword=meshcentral.dbpassword/dbpassword=${dbpass}/' config.txt

#Step 11. Cấu hình Nginx để chạy MeshCentral
echo 'server {'  >> /etc/nginx/sites-available/$FQDN.conf
echo '    server_name '${FQDN}';'>> /etc/nginx/sites-available/$FQDN.conf
echo '    location / {'>> /etc/nginx/sites-available/$FQDN.conf
echo '    proxy_pass http://localhost:8080;'>> /etc/nginx/sites-available/$FQDN.conf
echo '    proxy_http_version 1.1;'>> /etc/nginx/sites-available/$FQDN.conf
echo '    proxy_set_header Upgrade \$http_upgrade;'>> /etc/nginx/sites-available/$FQDN.conf
echo '    proxy_set_header Connection 'upgrade';'>> /etc/nginx/sites-available/$FQDN.conf
echo '    proxy_set_header Host \$host;'>> /etc/nginx/sites-available/$FQDN.conf
echo '    proxy_cache_bypass \$http_upgrade;'>> /etc/nginx/sites-available/$FQDN.conf
echo '    }'>> /etc/nginx/sites-available/$FQDN.conf
echo '}'>> /etc/nginx/sites-available/$FQDN.conf

#Save and close the file then verify the Nginx for any syntax error with the following command: 
nginx -t

#Step 12. gỡ bỏ apache:
sudo service apache2 stop
sudo apt-get purge apache2 apache2-utils apache2.2-bin apache2-common
sudo apt-get purge apache2 apache2-utils apache2-bin apache2.2-common

sudo apt-get autoremove
whereis apache2
apache2: /etc/apache2
sudo rm -rf /etc/apache2

sudo ln -s /usr/share/phpmyadmin /var/www/html/$FQDN/public/$phpmyadmin
sudo chown -R root:root /var/lib/phpmyadmin
sudo nginx -t

sudo systemctl restart nginx
systemctl restart php8.0-fpm.service

sudo ln -s /etc/nginx/sites-available/meshcentral /etc/nginx/sites-enabled/
sudo systemctl restart nginx

#Step 13. Cài đặt Certbot SSL
sudo apt install certbot python3-certbot-nginx -y
sudo certbot --nginx -d $FQDN

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
