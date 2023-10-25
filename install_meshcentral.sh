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
node -v
# v21.1.0

npm -v
#10.2.0

# Port Permission on Linux, as a Security feature, ports below 1024 port number are reserved for processes running as "root" user.
whereis node
# node: /usr/bin/node 
sudo setcap cap_net_bind_service=+ep /usr/bin/node

# Bước 5. Thiết lập thư mục và cấu hình quyền truy cập thư mục để Download MESHCENTRAL
#node: /usr/bin/node /usr/include/node /usr/share/man/man1/node.1.gz
# In this case, the result shows NodeJS binaries are found at /usr/bin/node. We will this path in the next command, which will allow NodeJS #to utilize ports below 1024. Note that these permissions may sometimes be lost when updating the Linux Kernel and the command may need to #be run again. 1)
# Now for our improved security installation, we are going to start by creating a new user called $mcadmin:

npm install meshcentral

node ./node_modules/meshcentral

# Bước 6. Cấu hình Dịch vụ cho MESHCENTRAL Service tự động chạy theo OS boot:
#Automatically Starting the Server
# We will need all of this information to create the description file for the $FQDN service we create. To create this description file, enter: 
mkdir /home/$mcadmin/$FQDN
mkdir /home/$mcadmin/$FQDN/meshcentralWD

echo '[Unit]' >>  /etc/systemd/system/$FQDN.service
echo 'Description='${FQDN}' Server' >> /etc/systemd/system/$FQDN.service
echo '[Service]'  >>  /etc/systemd/system/$FQDN.service
echo 'Type=simple'  >>  /etc/systemd/system/$FQDN.service
echo 'LimitNOFILE=1000000'  >>  /etc/systemd/system/$FQDN.service
echo 'ExecStart=/usr/bin/node /home/'${mcadmin}'/'${FQDN}'/node_modules/meshcentral'  >>  /etc/systemd/system/$FQDN.service
echo 'WorkingDirectory=/home/'${mcadmin}'/'${FQDN}'/meshcentralWD'  >>  /etc/systemd/system/$FQDN.service
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
sudo systemctl enable $FQDN.service
sudo systemctl start $FQDN.service

# Bước 7 (tuỳ chọn: dùng cài MONGODB làm Server nhúng CSDL quản lý MESHCENTRAL Address Book)
# By default, MeshCentral uses NeDB with a database file stored at ~/meshcentral-data/meshcentral.db. 
#While this is great for small servers #managing up to around 100 systems, as we indicated earlier, 
#this directory will become read-only in our improved security configuration, #so now it is time to tell MeshCentral to use MongoDB instead.
#The majority of the configuration options for MeshCentral are stored in a file called config.json, stored in the ~/meshcentral-data #directory. 
#We will edit it now to start using MongoDB. We start by opening the file in a text editor: 
#Inside the text editor, we need to make the top section of the file look like this:

echo '{' >> /home/$mcadmin/$FQDN/meshcentral-data/config.json
echo '  "$schema": "https://raw.githubusercontent.com/Ylianst/MeshCentral/master/meshcentral-config-schema.json",' >> /home/$mcadmin/$FQDN/meshcentral-data/config.json
echo '  "__comment1__": "This is a simple configuration file.",' >> /home/$mcadmin/$FQDN/meshcentral-data/config.json
echo '  "__comment2__": "See node_modules/meshcentral/sample-config-advanced.json.",' >> /home/$mcadmin/$FQDN/meshcentral-data/config.json
echo '  "settings": {' >> /home/$mcadmin/$FQDN/meshcentral-data/config.json
echo '    "_cert": "myserver.mydomain.com",' >> /home/$mcadmin/$FQDN/meshcentral-data/config.json
echo '    "WANonly": true,' >> /home/$mcadmin/$FQDN/meshcentral-data/config.json
echo '    "LANonly": true,' >> /home/$mcadmin/$FQDN/meshcentral-data/config.json
echo '    "_sessionKey": "MyReallySecretPassword1",' >> /home/$mcadmin/$FQDN/meshcentral-data/config.json
echo '    "port": 443,' >> /home/$mcadmin/$FQDN/meshcentral-data/config.json
echo '    "aliasPort": 443,' >> /home/$mcadmin/$FQDN/meshcentral-data/config.json
echo '    "redirPort": 80,' >> /home/$mcadmin/$FQDN/meshcentral-data/config.json
echo '    "redirAliasPort": 80' >> /home/$mcadmin/$FQDN/meshcentral-data/config.json
echo '  },' >> /home/$mcadmin/$FQDN/meshcentral-data/config.json
echo '  "domains": {' >> /home/$mcadmin/$FQDN/meshcentral-data/config.json
echo '    "": {' >> /home/$mcadmin/$FQDN/meshcentral-data/config.json
echo '      "_title": "MyServer",' >> /home/$mcadmin/$FQDN/meshcentral-data/config.json
echo '      "_title2": "Servername",' >> /home/$mcadmin/$FQDN/meshcentral-data/config.json
echo '      "_minify": true,' >> /home/$mcadmin/$FQDN/meshcentral-data/config.json
echo '      "_newAccounts": true,' >> /home/$mcadmin/$FQDN/meshcentral-data/config.json
echo '      "_userNameIsEmail": true' >> /home/$mcadmin/$FQDN/meshcentral-data/config.json
echo '    }' >> /home/$mcadmin/$FQDN/meshcentral-data/config.json
echo '  },' >> /home/$mcadmin/$FQDN/meshcentral-data/config.json
echo '  "_letsencrypt": {' >> /home/$mcadmin/$FQDN/meshcentral-data/config.json
echo '    "email": "myemail@mydomain.com",' >> /home/$mcadmin/$FQDN/meshcentral-data/config.json
echo '    "names": "myserver.mydomain.com",' >> /home/$mcadmin/$FQDN/meshcentral-data/config.json
echo '    "skipChallengeVerification": true,' >> /home/$mcadmin/$FQDN/meshcentral-data/config.json
echo '    "production": false' >> /home/$mcadmin/$FQDN/meshcentral-data/config.json
echo '  }' >> /home/$mcadmin/$FQDN/meshcentral-data/config.json
echo '}' >> /home/$mcadmin/$FQDN/meshcentral-data/config.json

# Bước 9 (tuỳ chọn: chỉ dùng cho vá lỗi nâng cấp phiên bản mới cho MESHCENTRAL)
#Updating MeshCentral
#As mentioned, with this improved security installation, the automated updates and updates initiated from the web portal will fail. To #update MeshCentral, you will need to log into the server over SSH and run the following commands:

#cd /home/$mcadmin/$FQDN
#sudo systemctl stop $FQDN.service
#sudo npm install meshcentral
#sudo -u $mcadmin node ./node_modules/meshcentral
#sudo chown -R $mcadmin:$mcadmin /home/$mcadmin/$FQDN
#sudo chmod 755 -R /home/$mcadmin/$FQDN/meshcentral-files
#sudo systemctl start $FQDN.service

fi
