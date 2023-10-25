#!/bin/bash
clear
cd ~
# https://meshcentral-community.com/doku.php?id=howto:installation:manual:ubuntu
# Bước 1: khai báo tham số hosting MESHCENTRAL 
############### Tham số cần thay đổi ở đây ###################
echo "FQDN: e.g: demo.company.vn"   # Đổi địa chỉ web thứ nhất Website Master for Resource code - để tạo cùng 1 Source code duy nhất 
read -e FQDN
echo "dbname: e.g: mcdata"   # Tên DBNane
read -e dbname
echo "dbuser: e.g: usermcdata"   # Tên User access DB lmsatcuser
read -e dbuser
echo "Database Password: e.g: P@$$w0rd-1.22"
read -s dbpass
echo "User MeshCentral Admin name: e.g: mcadmin"   # Đổi tên thư mục phpmyadmin khi add link symbol vào Website 
read -e mcadmin
echo "Group MeshCentral Admin name: e.g: mcgroup"   # Tên Thư mục Data vs Cache
read -e mcgroup
echo "Address Ethernet LAN IPv4 local for connect mongodb: e.g: 192.168.100.27"  # IPv4 of MONGODB Server allow connect to MESHCENTRAL
read -e etherip4

GitMCversion="1.1.13"
#===================================================================

echo "run install? (y/n)"
read -e run
if [ "$run" == n ] ; then
  exit
else

#Bước 2. Step by step Install MESHCENTRAL SERVER ==============
# The manual installation process is recommended for larger instances, or for administrators more familiar with installing and managing a #web server. No matter the OS of the host server, the general process is essentially the same:
#
# 1.   Install Nodejs and NPM
# 2.    Create a directory for MeshCentral to run from
# 3.    If it is to be a public-facing (WAN mode) server, verify you have public DNS record and IP Address assigned properly
# 4.    (optional) Install and configure MongoDB
# 5.    Install MeshCentral using NPM
# 6.    Adjust default configuration of MeshCentral
# 7.    Run MeshCentral
# 8.    Open required ports in the firewall
#===============================================================================

#Bước 3. Installing NodeJS
#The first prerequisite is to ensure NodeJS is installed on the system. We will install the node version manager, activate it, then install #an LTS version of NodeJS.
sudo apt update -y
sudo add-apt-repository universe -y
sudo apt install nano -y
sudo apt install nodejs -y
sudo apt install npm -y

# Bước 4. Check version và tình trạng hoạt động môi trường Node.js,  NPM và Node Server:
#Now we install nvm (Node Version Manager) - nvm makes keeping NodeJS up to date very simple. It also allows you to run multiple versions #of Nodejs side by side, or to roll back in case there are issues with a new version. If you are installing MeshCentral on Ubuntu 18.04, #the version of NodeJS included is very out of date, and does not meet the minimum requirements for MeshCentral. So getting nvm going first #will avoid a lot of headaches in the future. 
#wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
#You can either close out of your session, then reconnect to start using nvm, or if you are in a hurry, run the commands below to add nvm #to the system path, and add nvm to bash completion: 
#export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
# and now to manually load nvm: 
#[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
# Let's take a look and see what versions of Nodejs are currently available via nvm: 
#nvm ls-remote

#Looking at the list above, we will install the most recent LTS version: v18.18.2 
#nvm install v18.18.2

# Since nvm allows for multiple versions of Nodejs to be installed side by side, we are going to go ahead and tell it to use the version we just installed as the default: 
#nvm alias default v18.18.2

#nvm use default
#Now using node v18.18.2 (npm v10.2.1)

#Now we will update npm
#npm install npm@latest -g
#nvm install node
#v21.1.0 is already installed.
#Now using node v21.1.0 (npm v10.2.0)

#nvm use node
# Now using node v21.1.0 (npm v10.2.0)
node -v
# v21.1.0

npm -v
#10.2.0


# Installing MongoDB  (tuỳ chọn: phục vụ mô hình MESHCENTRAL Scale-out Larger > 100.000 Remote client)
sudo apt install mongodb -y
sudo systemctl start mongodb
sudo systemctl enable mongodb

#mongo --host 127.0.0.1:27017

# Then exit the Mongo shell by pressing CTRL-C.
# The database and log files will be created in these locations. This info is useful for making backups of the database.
# /var/log/mongodb
# /var/lib/mongo

# Port Permission on Linux, as a Security feature, ports below 1024 port number are reserved for processes running as "root" user.
whereis node
# node: /root/.nvm/versions/node/v21.1.0/bin/node
# node: /usr/bin/node 

sudo setcap cap_net_bind_service=+ep /usr/bin/node



# Bước 5. Thiết lập thư mục và cấu hình quyền truy cập thư mục để Download MESHCENTRAL
#node: /usr/bin/node /usr/include/node /usr/share/man/man1/node.1.gz
# In this case, the result shows NodeJS binaries are found at /usr/bin/node. We will this path in the next command, which will allow NodeJS #to utilize ports below 1024. Note that these permissions may sometimes be lost when updating the Linux Kernel and the command may need to #be run again. 1)
# Now for our improved security installation, we are going to start by creating a new user called $mcadmin:
 
sudo useradd -r -d /opt/$FQDN -s /sbin/nologin $mcadmin

mkdir /opt/$FQDN
cd /opt/$FQDN

npm install meshcentral
-u $mcadmin node ./node_modules/meshcentral
#node ./node_modules/meshcentral

# Bước 6. Cấu hình Dịch vụ cho MESHCENTRAL Service tự động chạy theo OS boot:
#Automatically Starting the Server
# whereis node
#  Node is usually installed at /usr/bin/node but if your check above shows a different path, make note of it and enter it into the appropriate place in the file we are about to create.
# We will need all of this information to create the description file for the $FQDN service we create. To create this description file, enter: 

echo '[Unit]' >>  /etc/systemd/system/$FQDN.service
echo 'Description='${FQDN}' Server' >> /etc/systemd/system/$FQDN.service
echo '[Service]'  >>  /etc/systemd/system/$FQDN.service
echo 'Type=simple'  >>  /etc/systemd/system/$FQDN.service
echo 'LimitNOFILE=1000000'  >>  /etc/systemd/system/$FQDN.service
echo 'ExecStart=/usr/bin/node /opt/'${FQDN}'/node_modules/meshcentral'  >>  /etc/systemd/system/$FQDN.service
echo 'WorkingDirectory=/opt/'${FQDN}''  >>  /etc/systemd/system/$FQDN.service
echo 'Environment=NODE_ENV=production'  >>  /etc/systemd/system/$FQDN.service
echo 'User='${mcadmin}''  >>  /etc/systemd/system/$FQDN.service
echo 'Group='${mcgroup}''  >>  /etc/systemd/system/$FQDN.service
echo 'Restart=always'  >>  /etc/systemd/system/$FQDN.service
echo '# Restart service after 10 seconds if node service crashes' >>  /etc/systemd/system/$FQDN.service
echo 'RestartSec=10'  >>  /etc/systemd/system/$FQDN.service
echo '# Set port permissions capability'  >>  /etc/systemd/system/$FQDN.service
echo 'AmbientCapabilities=cap_net_bind_service'  >>  /etc/systemd/system/$FQDN.service
echo '[Install]'  >>  /etc/systemd/system/$FQDN.service
echo 'WantedBy=multi-user.target'  >>  /etc/systemd/system/$FQDN.service

#Be sure to double check the path to NodeJS in the ExecStart line.
#Once we have this file created we can now enable, start, stop and disable MeshCentral:
#sudo systemctl disable $FQDN.service
sudo systemctl enable $FQDN.service
#sudo systemctl stop $FQDN.service
sudo systemctl start $FQDN.service
sudo systemctl status $FQDN.service

# Bước 7 Locking Things Down
# Now we are going to change ownership of the /opt/meshcentral directory and make it read only:

chown -R $mcadmin:$mcadmin /opt/$FQDN

# MeshCentral allows users to upload and download files stored on the server. These are all stored in the meshcentral-files directory. 
# Since we still want this to work, we need to adjust the permissions on this directory to allow the server to write to it:
mkdir /opt/$FQDN/meshcentral-files
chmod 755 /opt/$FQDN/meshcentral-files
chmod 755 /opt/$FQDN/meshcentral-*

#If you will be using the built in Let's Encrypt support for your MeshCentral instance, we will also need to adjust permissions on the #letsencrypt directory to allow those periodic updates to work properly:

mkdir /opt/$FQDN/meshcentral-data
mkdir /opt/$FQDN/meshcentral-data/letsencrypt
chmod 755 /opt/$FQDN/meshcentral-data/letsencrypt



# Bước 8 (tuỳ chọn: dùng cài MONGODB làm Server nhúng CSDL quản lý MESHCENTRAL Address Book)
# By default, MeshCentral uses NeDB with a database file stored at ~/meshcentral-data/meshcentral.db. While this is great for small servers #managing up to around 100 systems, as we indicated earlier, this directory will become read-only in our improved security configuration, #so now it is time to tell MeshCentral to use MongoDB instead.

#The majority of the configuration options for MeshCentral are stored in a file called config.json, stored in the ~/meshcentral-data #directory. We will edit it now to start using MongoDB. We start by opening the file in a text editor: 
#Inside the text editor, we need to make the top section of the file look like this:

echo '{' >> /opt/$FQDN/meshcentral-data/config.json
echo '	"settings": {' >> /opt/$FQDN/meshcentral-data/config.json
echo '    "MongoDb": "mongodb://127.0.0.1:27017/meshcentral",' >> /opt/$FQDN/meshcentral-data/config.json
echo '    "WANonly": true,' >> /opt/$FQDN/meshcentral-data/config.json
echo '    "_Port": 443,' >> /opt/$FQDN/meshcentral-data/config.json
echo '    "_RedirPort": 80,' >> /opt/$FQDN/meshcentral-data/config.json
echo '    "_AllowLoginToken": true,' >> /opt/$FQDN/meshcentral-data/config.json
echo '    "_AllowFraming": true,' >> /opt/$FQDN/meshcentral-data/config.json
echo '    "_WebRTC": false,' >> /opt/$FQDN/meshcentral-data/config.json
echo '    "_ClickOnce": false,' >> /opt/$FQDN/meshcentral-data/config.json
echo '    "_UserAllowedIP" : "127.0.0.1,::1,'${etherip4}'"' >> /opt/$FQDN/meshcentral-data/config.json
echo '  },' >> /opt/$FQDN/meshcentral-data/config.json
echo '}' >> /opt/$FQDN/meshcentral-data/config.json


# Bước 9 (tuỳ chọn: chỉ dùng cho vá lỗi nâng cấp phiên bản mới cho MESHCENTRAL)
#Updating MeshCentral
#As mentioned, with this improved security installation, the automated updates and updates initiated from the web portal will fail. To #update MeshCentral, you will need to log into the server over SSH and run the following commands:

#cd /opt/$FQDN
#sudo systemctl stop $FQDN.service
#sudo npm install meshcentral
#sudo -u $mcadmin node ./node_modules/meshcentral
#sudo chown -R $mcadmin:$mcadmin /opt/$FQDN
#sudo chmod 755 -R /opt/$FQDN/meshcentral-files
#sudo systemctl start $FQDN.service

fi
