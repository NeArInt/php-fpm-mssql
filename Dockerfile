FROM ubuntu:20.04
MAINTAINER  samuel@nearintegration.com
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get clean && apt-get -y update && apt-get install -y locales wget curl software-properties-common git \
  && locale-gen en_US.UTF-8
RUN LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php
RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install -y nano apt-transport-https php8.0-bcmath php8.0-bz2 php8.0-cli php8.0-common php8.0-curl \
                php8.0-cgi php8.0-dev php8.0-fpm php8.0-gd php8.0-gmp php8.0-imap php8.0-intl \
                php8.0-ldap php8.0-mbstring php8.0-mysql \
                php8.0-odbc php8.0-opcache php8.0-pgsql php8.0-phpdbg php8.0-pspell \
                php8.0-readline php8.0-soap php8.0-sqlite3 \
                php8.0-tidy php8.0-xml php8.0-xmlrpc php8.0-xsl php8.0-zip \
                php8.0-mongodb php8.0 mcrypt php-pear

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


RUN pear config-set php_ini /etc/php/8.0/fpm/php.ini
RUN printf "\n" | pecl install sqlsrv
RUN printf "\n" | pecl install pdo_sqlsrv
RUN printf "; priority=20\nextension=sqlsrv.so\n" > /etc/php/8.0/mods-available/sqlsrv.ini
RUN printf "; priority=30\nextension=pdo_sqlsrv.so\n" > /etc/php/8.0/mods-available/pdo_sqlsrv.ini
RUN phpenmod -v 8.0 sqlsrv pdo_sqlsrv


RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php/8.0/cli/php.ini
RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php/8.0/fpm/php.ini
RUN sed -i "s/memory_limit =.*/memory_limit = 1024M/" /etc/php/8.0/fpm/php.ini
RUN sed -i "s/display_errors = Off/display_errors = Off/" /etc/php/8.0/fpm/php.ini
RUN sed -i "s/upload_max_filesize = .*/upload_max_filesize = 100M/" /etc/php/8.0/fpm/php.ini
RUN sed -i "s/post_max_size = .*/post_max_size = 100M/" /etc/php/8.0/fpm/php.ini
RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/8.0/fpm/php.ini

RUN sed -i -e "s/pid =.*/pid = \/var\/run\/php8.0-fpm.pid/" /etc/php/8.0/fpm/php-fpm.conf
RUN sed -i -e "s/error_log =.*/error_log = \/proc\/self\/fd\/2/" /etc/php/8.0/fpm/php-fpm.conf
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/8.0/fpm/php-fpm.conf
RUN sed -i "s/listen = .*/listen = 9000/" /etc/php/8.0/fpm/pool.d/www.conf
RUN sed -i "s/;catch_workers_output = .*/catch_workers_output = yes/" /etc/php/8.0/fpm/pool.d/www.conf

RUN curl https://getcomposer.org/installer > composer-setup.php && php composer-setup.php && mv composer.phar /usr/local/bin/composer && rm composer-setup.php

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN apt-get update  -y

EXPOSE 9000
CMD ["php-fpm8.0"]