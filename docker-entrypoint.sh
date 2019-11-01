#!/bin/bash
set -e

if [ -z "$DB_HOSTNAME" ]; then
        echo >&2 'error: missing DB_HOSTNAME environment variable'
        exit 1
fi

if [ -z "$DB_USERNAME" ]; then
        echo >&2 'error: missing DB_USERNAME environment variable'
        exit 1
fi

if [ -z "$DB_PASSWORD" ]; then
        echo >&2 'error: missing DB_PASSWORD environment variable'
        exit 1
fi

if [ -z "$DB_NAME" ]; then
        echo >&2 'error: missing DB_NAME environment variable'
        exit 1
fi
####Adding block to check if vtiger data exists in the directory "/var/www/html". If not copy over the data#############
if [ -d "/var/www/html/vtigercrm" ]
then
    echo "Directory /var/www/html/vtigercrm exists."
else
    echo "Error: Directory /var/www/html/vtigercrm does not exists. Trying to create the directory with new data"
    echo "Creating directory /var/www/html/vtigercrm"
    mkdir -p /var/www/html/vtigercrm
    echo "Directory created downloading and copying code"
    curl -o vtigercrm.tar.gz -SL http://sourceforge.net/projects/vtigercrm/files/vtiger%20CRM%206.4.0/Core%20Product/vtigercrm6.4.0.tar.gz
    tar -xzf vtigercrm.tar.gz -C /var/www/html/
    rm vtigercrm.tar.gz
    echo "Directory /var/www/html/vtigercrm created and data copied, Applying correct permissions."
    cd /var/www/html/
    chmod -R 775 vtigercrm
    chown -R www-data:www-data vtigercrm
    echo "Permissions applied on /var/www/html/vtigercrm. Good to use now."
fi

###End of vtiger data block######################
sed -i "s/\$defaultParameters\['db_hostname'\]/'"${DB_HOSTNAME}"'/" vtigercrm/modules/Install/views/Index.php
sed -i "s/\$defaultParameters\['db_username'\]/'"${DB_USERNAME}"'/" vtigercrm/modules/Install/views/Index.php
sed -i "s/\$defaultParameters\['db_password'\]/'"${DB_PASSWORD}"'/" vtigercrm/modules/Install/views/Index.php
sed -i "s/\$defaultParameters\['db_name'\]/'"${DB_NAME}"'/" vtigercrm/modules/Install/views/Index.php

exec "$@"

