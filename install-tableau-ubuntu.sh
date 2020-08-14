#! /bin/bash

export TABLEAU_VERSION=2020.2.4
export TSM_USER_NAME=tsmadmin
export TSM_USER_PASSWORD=tsmadmin

sudo apt-get -y install git curl unzip gdebi-core
git clone https://github.com/tableau/server-install-script-samples server-install --depth 3

# Download the tableau server binaries (https://www.tableau.com/support/releases/server)
curl "https://downloads.tableau.com/esdalt/${TABLEAU_VERSION}/tableau-server-${TABLEAU_VERSION//\./-}_amd64.deb" --output "tableau-server-${TABLEAU_VERSION//\./-}_amd64.deb"

sudo useradd -m ${TSM_USER_NAME} && echo "${TSM_USER_NAME}:${TSM_USER_PASSWORD}" | sudo chpasswd && sudo adduser ${TSM_USER_NAME} sudo

echo 'seq 0 9 | xargs -I% -- echo %,%' \
	| sudo tee /usr/local/bin/lscpu \
	&& sudo chmod +x /usr/local/bin/lscpu

# To run a Tableau Server cluster, you must disable temporary IPv6 addresses on all nodes in the cluster. For details, see:
# http://kb.tableau.com/articles/knowledgebase/temporary-ipv6 (Disabling temporary IPv6 addresses)
sudo ./server-install/linux/automated-installer/automated-installer \
    -s ./tableau/config/secrets \
    -f ./tableau/config/config.json \
    -r ./tableau/config/registration.json \
    --accepteula \
    -a tsmadmin \
    "./tableau-server-${TABLEAU_VERSION//\./-}_amd64.deb"

sudo /opt/tableau/tableau_server/packages/scripts.20202.20.0721.1350/initialize-tsm --accepteula

# Download tableau drivers (https://www.tableau.com/support/drivers)
curl "https://downloads.tableau.com/drivers/linux/deb/tableau-driver/tableau-postgresql-odbc_09.06.0501_amd64.deb" --output "tableau-postgresql-odbc_09.06.0501_amd64.deb"
curl "https://downloads.tableau.com/drivers/linux/deb/tableau-driver/tableau-freetds_1.00.40_amd64.deb" --output "tableau-freetds_1.00.40_amd64.deb"
curl "https://downloads.tableau.com/drivers/microsoft/sharepoint/Linux/SharePoint_Tableau_6883.x86_64.deb" --output "SharePoint_Tableau_6883.x86_64.deb"

sudo gdebi -n tableau-postgresql-odbc_09.06.0501_amd64.deb
sudo gdebi -n tableau-freetds_1.00.40_amd64.deb

sudo apt-get update && sudo apt-get install -y iodbc unixodbc-dev
sudo gdebi -n SharePoint_Tableau_6883.x86_64.deb

# Setup ngrok

sudo cp ngrok.service /lib/systemd/system/

sudo mkdir -p /opt/ngrok
cp ngrok.yml /opt/ngrok

cd /opt/ngrok
curl https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip
unzip ngrok-stable-linux-amd64.zip
rm ngrok-stable-linux-amd64.zip
sudo chmod +x ngrok

sudo systemctl enable ngrok.service
sudo systemctl start ngrok.service

# install xrdp

sudo apt-get -y remove dbus-user-session
sudo apt-get -y install dbus-x11 xrdp
sudo adduser xrdp ssl-cert
sudo ufw allow 3389

# Set some settings - needs to be run manually from as the tsmadmin user created above after tableau is installed
# tsm configuration set -k wgserver.clickjack_defense.enabled -v false
# tsm configuration set -k content_security_policy.directive.script_src -v "* blob: 'unsafe-eval'"
# tsm pending-changes apply