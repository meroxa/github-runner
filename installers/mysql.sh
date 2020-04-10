#!/bin/bash
################################################################################
##  File:  mysql.sh
##  Desc:  Installs MySQL Client
################################################################################

## Source the helpers for use with the script
source $HELPER_SCRIPTS/document.sh

export ACCEPT_EULA=Y

sudo echo "mysql-server mysql-server/root_password password root" | debconf-set-selections
sudo echo "mysql-server mysql-server/root_password_again password root" | debconf-set-selections

# UTF-8 and bind-address
sudo sed -i -e "$ a [client]\n\n[mysql]\n\n[mysqld]"  /etc/mysql/my.cnf
sudo sed -i -e "s/\(\[client\]\)/\1\ndefault-character-set = utf8/g" /etc/mysql/my.cnf
sudo sed -i -e "s/\(\[mysql\]\)/\1\ndefault-character-set = utf8/g" /etc/mysql/my.cnf
sudo sed -i -e "s/\(\[mysqld\]\)/\1\ninit_connect='SET NAMES utf8'\ncharacter-set-server = utf8\ncollation-server=utf8_unicode_ci\nbind-address = 0.0.0.0/g" /etc/mysql/my.cnf

# Install MySQL Client
apt-get install mysql-client -y

# InstallMySQL database development files
apt-get install libmysqlclient-dev -y

apt-get install -y mysql-server
sudo mkdir -p /var/lib/mysql
sudo mkdir -p /var/run/mysqld
sudo mkdir -p /var/log/mysql
sudo chown -R mysql:mysql /var/lib/mysql
sudo chown -R mysql:mysql /var/run/mysqld
sudo chown -R mysql:mysql /var/log/mysql

# Install MS SQL Server client tools (https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-setup-tools?view=sql-server-2017)
apt-get install -y mssql-tools unixodbc-dev
apt-get -f install
ln -s /opt/mssql-tools/bin/* /usr/local/bin/

# Run tests to determine that the software installed as expected
echo "Testing to make sure that script performed as expected, and basic scenarios work"
if ! command -v mysql; then
  echo "mysql was not installed"
  exit 1
fi

# Document what was added to the image
echo "Lastly, documenting what we added to the metadata file"
DocumentInstalledItem "MySQL ($(mysql --version))"
DocumentInstalledItem "MS SQL Server Client Tools"
