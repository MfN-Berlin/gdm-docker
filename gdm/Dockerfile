FROM php:7.0-apache

ENV GDM_VERSION=v0.5beta

# install some packages
RUN  \
     echo 'deb http://packages.dotdeb.org jessie all' >> /etc/apt/sources.list \
  && echo 'deb-src http://packages.dotdeb.org jessie all' >> /etc/apt/sources.list \
  && apt-get update \
  && apt-get install -y apt-utils wget \
  && wget https://www.dotdeb.org/dotdeb.gpg \
  && apt-key add dotdeb.gpg 

# install pdo_mysql
RUN \
     apt-get install -y --force-yes php7.0-mysql \
  && docker-php-ext-install pdo_mysql \
  && apt-get install -y --force-yes libapache2-mod-php7.0 \
  && apt-get install -y --force-yes zip unzip nano

# install nodejs and npm
RUN curl -sL https://deb.nodesource.com/setup_7.x | bash -
RUN apt-get -y install nodejs

# clean-up
RUN apt-get clean

RUN echo prefix=~/.npm-packages >> ~/.npmrc && \
    curl -L https://www.npmjs.com/install.sh | sh && \
    export PATH="$HOME/.npm-packages/bin:$PATH"

RUN curl -sS https://getcomposer.org/installer | \
    php -- --install-dir=/usr/local/bin --filename=composer

# create home directory 
ENV GDM_HOME /usr/share/gdm
RUN mkdir -p $GDM_HOME && cd $GDM_HOME/

# install dependencies with composer
RUN     cd / && cd $GDM_HOME && \
        composer require doctrine/dbal && \
        composer require ignasbernotas/laravel-model-generator --dev
		
RUN cd $GDM_HOME && \
	npm install --save gulp-cli gulp 


# download release file from public repository only
#RUN cd $GDM_HOME && \
#    curl -L -o /tmp/gdm_$GDM_VERSION.tgz https://github.com/MfN-Berlin/gdm/archive/$GDM_VERSION.tar.gz
# or alternatively use file that has been downloaded already
	COPY gdm_$GDM_VERSION.tgz   /tmp/gdm_$GDM_VERSION.tgz


RUN cd  /tmp && \
    tar -xvf gdm_$GDM_VERSION.tgz

# The tar file comes with a parent directory that is named by the individual master version id. So it varies over time.
# Thus, move all files (excluding hidden files) from the parent directory to $GDM_HOME and remove the parent dir that is left behind empty.
RUN cd /tmp/ && \
    mv $(find . -name "gdm-*")/* $GDM_HOME/ && \
    rm -Rf $(find . -name "gdm-*")


# copy customized model generator files
RUN cd $GDM_HOME && \
    cp lib/tools/model.stub  vendor/ignasbernotas/laravel-model-generator/src/stubs/model.stub && \
    cp lib/tools/MakeModelsCommand.php vendor/ignasbernotas/laravel-model-generator/src/Commands/MakeModelsCommand.php


RUN cd $GDM_HOME && \
	composer dump-autoload  && \
	composer install --no-scripts  && \
	composer update --no-scripts 
	
	
VOLUME [ $GDM_HOME/custom ]

# avoid permission issues in the mounted volume by adding the user www-data to a docker group
RUN groupadd -g 999 docker
RUN usermod -a -G docker www-data

RUN chown -R www-data $GDM_HOME/
RUN chown -R www-data /var/log/apache2/


# execute database seeder/root/.npm-packages/lib/node_modules/gulp/bin/gulp.js
#RUN cd $GDM_HOME && \
#	gulp --production

RUN cd $GDM_HOME && \
	composer dump-autoload && \
	#mkdir app/Models && \
	chmod -R g+w app/Models && \
	chmod -R g+w app/Http/Controllers && \
	#touch app/Http/routes_datamodel.php && \
	chmod -R g+w app/Http/routes_datamodel.php && \
	#touch resources/views/partials/menu-items.blade.php && \
	chmod -R g+w resources/views  && \
	\
	chgrp -R www-data app/Models && \
	chgrp -R www-data app/Http/Controllers && \
	chgrp -R www-data resources/views && \
	chgrp  www-data app/Http/routes_datamodel.php


	# link files from volume
RUN ln -sf $GDM_HOME/custom/.env $GDM_HOME/.env 


## Apache config

#enable mod_rewrite
RUN a2enmod rewrite

RUN ln -sf $GDM_HOME/custom/000-default.conf /etc/apache2/sites-available/000-default.conf
	
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2

RUN mkdir -p $APACHE_RUN_DIR $APACHE_LOCK_DIR $APACHE_LOG_DIR
	
# link log files
RUN ln -sf /dev/stdout /var/log/apache2/access.log && \
    ln -sf /dev/stderr /var/log/apache2/error.log

WORKDIR $GDM_HOME

EXPOSE 80
EXPOSE 443

ENTRYPOINT [ "/usr/sbin/apache2" ]
CMD ["-D", "FOREGROUND"]

