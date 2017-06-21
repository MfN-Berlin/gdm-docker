FROM java

MAINTAINER Falko Gloeckler

ENV LIQUIBASE_VERSION=3.5.3

# download liquibase
ADD https://github.com/liquibase/liquibase/releases/download/liquibase-parent-$LIQUIBASE_VERSION/liquibase-$LIQUIBASE_VERSION-bin.tar.gz /tmp/liquibase-$LIQUIBASE_VERSION-bin.tar.gz

# Create a directory for liquibase
RUN mkdir /opt/liquibase

# Unpack the distribution
RUN tar -xzf /tmp/liquibase-$LIQUIBASE_VERSION-bin.tar.gz -C /opt/liquibase
RUN chmod +x /opt/liquibase/liquibase

# Symlink to liquibase to be on the path
RUN ln -s /opt/liquibase/liquibase /usr/local/bin/

# Get the postgres JDBC driver from http://jdbc.postgresql.org/download.html
ADD http://jdbc.postgresql.org/download/postgresql-9.3-1102.jdbc41.jar /opt/jdbc_drivers/
RUN ln -s /opt/jdbc_drivers/postgresql-9.3-1102.jdbc41.jar /usr/local/bin/


# Get MySQL JDBC driver from 
ADD https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.42.tar.gz /tmp/mysql-connector-java-5.1.42.tar.gz
RUN cd  /tmp && \
	tar -xzf /tmp/mysql-connector-java-5.1.42.tar.gz
RUN cp -R /tmp/mysql-connector-java-5.1.42/mysql-connector-java-5.1.42-bin.jar /opt/jdbc_drivers/
RUN ln -s /opt/jdbc_drivers/mysql-connector-java-5.1.42-bin.jar /usr/local/bin/

# Add command scripts
# ADD scripts /scripts
# RUN chmod -R +x /scripts

VOLUME ["/changelogs"]

WORKDIR /

#ENTRYPOINT ["/bin/bash"]
ENTRYPOINT ["/usr/local/bin/liquibase"]