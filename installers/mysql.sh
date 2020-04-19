#!/bin/bash
################################################################################
##  File:  mysql.sh
##  Desc:  Installs MySQL Client
##         https://github.com/docker-library/mysql/blob/master/5.7/Dockerfile
################################################################################

## Source the helpers for use with the script
source $HELPER_SCRIPTS/document.sh

export ACCEPT_EULA=Y

# Install MySQL Client
apt-get install mysql-client -y

# InstallMySQL database development files
apt-get install libmysqlclient-dev -y

# Install MySQL Server
MYSQL_ROOT_PASSWORD=root
{
  echo mysql-server mysql-server/data-dir select '';
  echo mysql-server mysql-server/root-pass $MYSQL_ROOT_PASSWORD '';
  echo mysql-server mysql-server/re-root-pass $MYSQL_ROOT_PASSWORD '';
  echo mysql-server mysql-server/remove-test-db select false;
} | debconf-set-selections

apt-get install -y mysql-server
rm -rf /var/lib/mysql
mkdir -p /var/lib/mysql /var/run/mysqld
chown -R mysql:mysql /var/lib/mysql /var/run/mysqld
chmod 777 /var/run/mysqld
find /etc/mysql/ -name '*.cnf' -print0 \
  | xargs -0 grep -lZE '^(bind-address|log)' \
  | xargs -rt -0 sed -Ei 's/^(bind-address|log)/#&/'
echo '[mysqld]\nskip-host-cache\nskip-name-resolve' > /etc/mysql/conf.d/docker.cnf

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

set -e
mysql -vvv -e 'CREATE DATABASE smoke_test' -uroot -proot
mysql -vvv -e 'DROP DATABASE smoke_test' -uroot -proot
set +e

# Document what was added to the image
echo "Lastly, documenting what we added to the metadata file"
DocumentInstalledItem "MySQL ($(mysql --version))"
DocumentInstalledItem "MySQL Server (user:root password:root)"
DocumentInstalledItem "MS SQL Server Client Tools"

# Disable mysql.service
systemctl is-active --quiet mysql.service && systemctl stop mysql.service 
systemctl disable mysql.service 
