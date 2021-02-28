FROM ubuntu:20.04
MAINTAINER  samuel@nearintegration.com
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get clean && apt-get -y update && apt-get install -y locales wget curl software-properties-common git \
  && locale-gen en_US.UTF-8
RUN LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php
RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install -y nano apt-transport-https php7.4-bcmath php7.4-bz2 php7.4-cli php7.4-common php7.4-curl \
                php7.4-cgi php7.4-dev php7.4-fpm php7.4-gd php7.4-gmp php7.4-imap php7.4-intl \
                php7.4-json php7.4-ldap php7.4-mbstring php7.4-mysql \
                php7.4-odbc php7.4-opcache php7.4-pgsql php7.4-phpdbg php7.4-pspell \
                php7.4-readline php7.4-soap php7.4-sqlite3 \
                php7.4-tidy php7.4-xml php7.4-xmlrpc php7.4-xsl php7.4-zip \
                php-tideways php-mongodb php7.4 mcrypt php-pear

RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN apt-get update  -y
RUN apt-get upgrade  -y
RUN ACCEPT_EULA=Y apt-get install -y msodbcsql17
RUN ACCEPT_EULA=Y apt-get install -y mssql-tools
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
RUN /bin/bash -c "source ~/.bashrc"
RUN apt-get install -y unixodbc-dev


RUN pear config-set php_ini `php --ini | grep "Loaded Configuration" | sed -e "s|.*:\s*||"` system
RUN printf "\n" | pecl install sqlsrv
RUN printf "\n" | pecl install pdo_sqlsrv
RUN echo "extension=sqlsrv.so" | tee --append /etc/php/7.4/fpm/php.ini
RUN echo "extension=pdo_sqlsrv.so" | tee --append /etc/php/7.4/fpm/php.ini


RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php/7.4/cli/php.ini
RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php/7.4/fpm/php.ini
RUN sed -i "s/memory_limit =.*/memory_limit = 256M/" /etc/php/7.4/fpm/php.ini
RUN sed -i "s/display_errors = Off/display_errors = Off/" /etc/php/7.4/fpm/php.ini
RUN sed -i "s/upload_max_filesize = .*/upload_max_filesize = 100M/" /etc/php/7.4/fpm/php.ini
RUN sed -i "s/post_max_size = .*/post_max_size = 100M/" /etc/php/7.4/fpm/php.ini
RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.4/fpm/php.ini

RUN sed -i -e "s/pid =.*/pid = \/var\/run\/php7.4-fpm.pid/" /etc/php/7.4/fpm/php-fpm.conf
RUN sed -i -e "s/error_log =.*/error_log = \/proc\/self\/fd\/2/" /etc/php/7.4/fpm/php-fpm.conf
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/7.4/fpm/php-fpm.conf
RUN sed -i "s/listen = .*/listen = 9000/" /etc/php/7.4/fpm/pool.d/www.conf
RUN sed -i "s/;catch_workers_output = .*/catch_workers_output = yes/" /etc/php/7.4/fpm/pool.d/www.conf

RUN curl https://getcomposer.org/installer > composer-setup.php && php composer-setup.php && mv composer.phar /usr/local/bin/composer && rm composer-setup.php

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN apt-get update  -y

EXPOSE 9000
CMD ["php-fpm7.4"]