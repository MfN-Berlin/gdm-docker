FROM php:7.0-apache

#enable mod_rewrite
RUN a2enmod rewrite

#install some packages
RUN  \
     echo 'deb http://packages.dotdeb.org jessie all' >> /etc/apt/sources.list \
  && echo 'deb-src http://packages.dotdeb.org jessie all' >> /etc/apt/sources.list \
  && apt-get update \
  && apt-get install -y apt-utils wget \
  && wget https://www.dotdeb.org/dotdeb.gpg \
  && apt-key add dotdeb.gpg 

#install pdo_mysql
RUN \
     apt-get install -y --force-yes php7.0-mysql \
  && docker-php-ext-install pdo_mysql \
  && apt-get install -y --force-yes libapache2-mod-php7.0 \
  && apt-get install -y --force-yes zip unzip nano

#install nodejs and npm
RUN curl -sL https://deb.nodesource.com/setup_7.x | bash -
RUN apt-get -y install nodejs

RUN echo prefix=~/.npm-packages >> ~/.npmrc && \
    curl -L https://www.npmjs.com/install.sh | sh && \
    export PATH="$HOME/.npm-packages/bin:$PATH"

RUN curl -sS https://getcomposer.org/installer | \
        php -- --install-dir=/usr/local/bin --filename=composer

#create home directory 
ENV GDM_HOME /usr/share/app
RUN mkdir $GDM_HOME -p && cd $GDM_HOME/

# provide a sample docker environment file
COPY .env.docker $GDM_HOME/.env

# install dependencies with composer
RUN     cd / && cd $GDM_HOME && \
        composer require doctrine/dbal && \
        composer require ignasbernotas/laravel-model-generator --dev

# download release file from public repository only
#RUN cd $GDM_HOME && \
#    curl -o gdm_latest.tgz https://code.naturkundemuseum.berlin/Thomas.Pfuhl/pmd/repository/archive.tar.gz?ref=master
#
# temporary alternative for download
COPY gdm_latest.tgz /tmp/
RUN cd  /tmp && \
    tar -xzf gdm_latest.tgz

# The tar file comes with a parent directory that is named by the individual master version id. So it varies over time.
# Thus, move all file (excluding hidden files) from the parent directory to $GDM_HOME and remove the parent dir that is left behind empty.
RUN cd /tmp/ && \
    mv $(find . -name "pmd-master-*")/* $GDM_HOME/ && \
    rm -Rf $(find . -name "pmd-master-*")

# copy customized about-file
COPY about.html $GDM_HOME/public/appfiles/about.html

#RUN cd $GDM_HOME &&  composer update 
RUN cd $GDM_HOME &&  composer update --no-scripts
# cf. http://stackoverflow.com/questions/43769756/composer-install-doesnt-install-packages-when-running-in-dockerfile

# copy customized model generator files
RUN cd $GDM_HOME && \
    cp lib/tools/model.stub  vendor/ignasbernotas/laravel-model-generator/src/stubs/model.stub && \
    cp lib/tools/MakeModelsCommand.php  vendor/ignasbernotas/laravel-model-generator/src/Commands/MakeModelsCommand.php

#######################
# liquibase

# install jre
RUN apt-get install -y --force-yes default-jre 

# load environment variables
# ISSUE !!!  ugly workaround, we should import them from the laravel environement file for shell variables
ENV DB_CONNECTION   mysql
ENV DB_HOST         $DB_HOST
ENV DB_DATABASE     $DB_NAME
ENV DB_USERNAME     $DB_USER
ENV DB_PASSWORD     $DB_PASSWORD


#make our own apache configuration, already defined in .env.docker    
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2

RUN ln -sf /dev/stdout /var/log/apache2/access.log && \
    ln -sf /dev/stderr /var/log/apache2/error.log

RUN mkdir -p $APACHE_RUN_DIR $APACHE_LOCK_DIR $APACHE_LOG_DIR

RUN cd $GDM_HOME && \
    cp lib/tools/000-default.conf /etc/apache2/sites-available/

WORKDIR $GDM_HOME/public

RUN chown -R www-data $GDM_HOME/

EXPOSE 80

VOLUME [ "/usr/share/app/.env" ]

ENTRYPOINT [ "/usr/sbin/apache2" ]
CMD ["-D", "FOREGROUND"]

