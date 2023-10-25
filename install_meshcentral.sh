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
echo "User MeshCentral Admin name: e.g: mcadmin"   # Đổi tên thư mục phpmyadmin khi add link symbol vào Website 
read -e mcadmin
echo "Group MeshCentral Admin name: e.g: mcgroup"   # Tên Thư mục Data vs Cache
read -e mcgroup

GitMCversion="1.1.13"
#===================================================================

echo "run install? (y/n)"
read -e run
if [ "$run" == n ] ; then
  exit
else

#================= Step by step Install MESHCENTRAL SERVER ==============
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

#Installing NodeJS
#The first prerequisite is to ensure NodeJS is installed on the system. We will install the node version manager, activate it, then install #an LTS version of NodeJS.

sudo add-apt-repository universe -y
sudo apt update -y
sudo apt install npm -y
sudo apt install nano -y

#Now we install nvm (Node Version Manager) - nvm makes keeping NodeJS up to date very simple. It also allows you to run multiple versions #of Nodejs side by side, or to roll back in case there are issues with a new version. If you are installing MeshCentral on Ubuntu 18.04, #the version of NodeJS included is very out of date, and does not meet the minimum requirements for MeshCentral. So getting nvm going first #will avoid a lot of headaches in the future. 

#wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
#You can either close out of your session, then reconnect to start using nvm, or if you are in a hurry, run the commands below to add nvm #to the system path, and add nvm to bash completion: 
#export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
# and now to manually load nvm: 

#[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Let's take a look and see what versions of Nodejs are currently available via nvm: 
#nvm ls-remote

node -v
npm -v
whereis node
#node: /usr/bin/node /usr/include/node /usr/share/man/man1/node.1.gz

# In this case, the result shows NodeJS binaries are found at /usr/bin/node. We will this path in the next command, which will allow NodeJS #to utilize ports below 1024. Note that these permissions may sometimes be lost when updating the Linux Kernel and the command may need to #be run again. 1)

sudo setcap cap_net_bind_service=+ep /usr/bin/node

sudo mkdir /opt/$FQDN
cd /opt/$FQDN
sudo npm install meshcentral
sudo -u $mcadmin node ./node_modules/meshcentral

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
sudo systemctl disable meshcentral.service
sudo systemctl enable meshcentral.service
sudo systemctl stop meshcentral.service
sudo systemctl start meshcentral.service


#Updating MeshCentral
#As mentioned, with this improved security installation, the automated updates and updates initiated from the web portal will fail. To #update MeshCentral, you will need to log into the server over SSH and run the following commands:

cd /opt/meshcentral
sudo systemctl stop meshcentral
sudo npm install meshcentral
sudo -u $mcadmin node ./node_modules/meshcentral
sudo chown -R $mcadmin:$mcadmin /opt/$FQDN
sudo chmod 755 -R /opt/$FQDN/meshcentral-files
sudo systemctl start meshcentral

fi
