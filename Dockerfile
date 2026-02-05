FROM ubuntu:24.04
MAINTAINER samuel@nearintegration.com
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get clean && apt-get -y update && apt-get install -y locales wget curl software-properties-common gnupg2 git \
  && locale-gen en_US.UTF-8
RUN LC_ALL=en_US.UTF-8 add-apt-repository ppa:ondrej/php
RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install -y nano apt-transport-https php8.3-bcmath php8.3-bz2 php8.3-cli php8.3-common php8.3-curl \
                php8.3-cgi php8.3-dev php8.3-fpm php8.3-gd php8.3-gmp php8.3-imap php8.3-intl \
                php8.3-ldap php8.3-mbstring php8.3-mysql \
                php8.3-odbc php8.3-opcache php8.3-pgsql php8.3-phpdbg php8.3-pspell \
                php8.3-readline php8.3-soap php8.3-sqlite3 \
                php8.3-tidy php8.3-xml php8.3-xmlrpc php8.3-xsl php8.3-zip \
                php8.3-mongodb php8.3 mcrypt php-pear

RUN curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
RUN curl https://packages.microsoft.com/config/ubuntu/24.04/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN apt-get update -y
RUN apt-get upgrade -y
RUN ACCEPT_EULA=Y apt-get install -y msodbcsql18
RUN ACCEPT_EULA=Y apt-get install -y mssql-tools18
RUN echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.bash_profile
RUN echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> ~/.bashrc
RUN /bin/bash -c "source ~/.bashrc"
RUN apt-get install -y unixodbc-dev

RUN pear config-set php_ini /etc/php/8.3/fpm/php.ini
RUN printf "\n" | pecl install sqlsrv
RUN printf "\n" | pecl install pdo_sqlsrv
RUN printf "; priority=20\nextension=sqlsrv.so\n" > /etc/php/8.3/mods-available/sqlsrv.ini
RUN printf "; priority=30\nextension=pdo_sqlsrv.so\n" > /etc/php/8.3/mods-available/pdo_sqlsrv.ini
RUN phpenmod -v 8.3 sqlsrv pdo_sqlsrv

RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php/8.3/cli/php.ini
RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php/8.3/fpm/php.ini
RUN sed -i "s/memory_limit =.*/memory_limit = 1024M/" /etc/php/8.3/fpm/php.ini
RUN sed -i "s/display_errors = Off/display_errors = Off/" /etc/php/8.3/fpm/php.ini
RUN sed -i "s/upload_max_filesize = .*/upload_max_filesize = 100M/" /etc/php/8.3/fpm/php.ini
RUN sed -i "s/post_max_size = .*/post_max_size = 100M/" /etc/php/8.3/fpm/php.ini
RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/8.3/fpm/php.ini

RUN sed -i -e "s/pid =.*/pid = \/var\/run\/php8.3-fpm.pid/" /etc/php/8.3/fpm/php-fpm.conf
RUN sed -i -e "s/error_log =.*/error_log = \/proc\/self\/fd\/2/" /etc/php/8.3/fpm/php-fpm.conf
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/8.3/fpm/php-fpm.conf
RUN sed -i "s/listen = .*/listen = 9000/" /etc/php/8.3/fpm/pool.d/www.conf
RUN sed -i "s/;catch_workers_output = .*/catch_workers_output = yes/" /etc/php/8.3/fpm/pool.d/www.conf

RUN curl https://getcomposer.org/installer > composer-setup.php && php composer-setup.php && mv composer.phar /usr/local/bin/composer && rm composer-setup.php

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN apt-get update -y

EXPOSE 9000
CMD ["php-fpm8.3"]
