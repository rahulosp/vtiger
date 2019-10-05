FROM php:5.6-apache

RUN a2enmod rewrite expires

# install the PHP extensions we need
RUN apt-get update && apt-get install -y libpng-dev libjpeg-dev libkrb5-dev \
    && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
    && docker-php-ext-install gd mysqli \
    && apt-get -y install libssl-dev libc-client2007e-dev libkrb5-dev \
    && docker-php-ext-configure imap --with-imap-ssl --with-kerberos \
    && docker-php-ext-install imap opcache \
    && rm -rf /var/lib/apt/lists/*

# setting the recommended for vtiger
RUN { \
        echo 'display_errors=On'; \
        echo 'max_execution_time=0'; \
        echo 'error_reporting=E_WARNING & ~E_NOTICE & ~E_DEPRECATED'; \
        echo 'log_errors=Off'; \
        echo 'short_open_tag=On'; \
    } > /usr/local/etc/php/conf.d/vtiger-recommended.ini

# setting the reccomended for opcache
# https://secure.php.net/manual/en/opcache.installation.php
RUN { \
        echo 'opcache.memory_consumption=128'; \
        echo 'opcache.interned_strings_buffer=8'; \
        echo 'opcache.max_accelerated_files=4000'; \
        echo 'opcache.revalidate_freq=60'; \
        echo 'opcache.fast_shutdown=1'; \
        echo 'opcache.enable_cli=1'; \
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini

VOLUME /var/www/html

WORKDIR /var/www/html

#RUN curl -o vtigercrm.tar.gz -SL http://sourceforge.net/projects/vtigercrm/files/vtiger%20CRM%206.4.0/Core%20Product/vtigercrm6.4.0.tar.gz \
#    && tar -xzf vtigercrm.tar.gz -C /usr/src/ \
#    && rm vtigercrm.tar.gz \
#    && cd /usr/src/ \
#    && chmod -R 775 vtigercrm \
#    && chown -R www-data:www-data vtigercrm

###Create TLS encryption on website, use HTTPS. Copy certificates and write apache ssl conf file
RUN mkdir -p /etc/apache2/certs
COPY vtiger.crt /etc/apache2/certs/
COPY vtiger.key /etc/apache2/certs/
RUN chmod 400 /etc/apache2/certs/vtiger.key
COPY vtiger-ssl.conf /etc/apache2/sites-available/
RUN a2enmod ssl && a2ensite vtiger-ssl
###Creation of TLS encrypted vtiger site terminates here.

COPY docker-entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["apache2-foreground"]
