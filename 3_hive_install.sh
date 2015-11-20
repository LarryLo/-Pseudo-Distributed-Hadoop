#!/bin/bash

logPrefix="hive-install"
location=$(pwd)
hiveTar="apache-hive-1.2.1-bin.tar.gz"
hivePath="tar/$hiveTar"
RETVAL=0

loggerInfo() {
    printf "%s %s %s : %s\n" `date +%Y%m%d-%H:%M:%S` $logPrefix "INFO" "$1"
}

loggerError() {
    printf "%s %s %s : %s\n" `date +%Y%m%d-%H:%M:%S` $logPrefix "ERROR" "$1"
}

hiveInstall() {
    if [[ ! -f /opt/.hive-install ]]; then
        tar zxvf $hivePath -C /opt/
        mv /opt/apache-hive-1.2.1-bin /opt/hive
        loggerInfo "Start to set HIVE_HOME append to PATH"
        sed -i '/export HADOOP_HOME=\/opt\/hadoop/a export HIVE_HOME=\/opt\/hive' /etc/profile
        sed -i '/^export PATH=/ s/$/:\$HIVE_HOME\/bin/' /etc/profile
        if [[ $? -eq 0 ]]; then
            touch /opt/.hive-install 
            source /etc/profile
        fi
        else 
            loggerInfo "Hive has been installed."
    fi
}
postgreInstall() {
    # Reference from: http://www.cloudera.com/content/www/en-us/documentation/enterprise/latest/topics/cdh_ig_hive_metastore_configure.html
    loggerInfo "Start to install postgreSQL."
    yum -y install postgresql-server
    if [[ $? -eq 0 ]]; then
        service postgresql initdb
        # edit postgresql.conf
        sed -i "s/\#listen_addresses = 'localhost'/listen_addresses = '\*'/g" /var/lib/pgsql/data/postgresql.conf  
        sed -i "s/\#standard_conforming_strings/standard_conforming_strings/g" /var/lib/pgsql/data/postgresql.conf 
        echo "host all all 0.0.0.0/0 md5" >> /var/lib/pgsql/data/pg_hba.conf 
        service postgresql start
        chkconfig postgresql on
        # install jdbc for hive-metastore
        yum -y install postgresql-jdbc
        if [[ $? -eq 0 ]]; then
            ln -s /usr/share/java/postgresql-jdbc.jar /opt/hive/lib/postgresql-jdbc.jar
            cd /opt/hive/scripts/metastore/upgrade/postgres
            sudo -u postgres psql -c "CREATE USER hive WITH PASSWORD '12345'" 
            sudo -u postgres psql -c "CREATE DATABASE metastore" 
            sudo -u postgres psql -f /opt/hive/scripts/metastore/upgrade/postgres/hive-schema-1.2.0.postgres.sql metastore
            sudo -u postgres psql -f $location/sql/grant-permission-for-hive.sql
        fi 
    fi 
}

hiveConfig() {
    loggerInfo "Start to set Hive Configuration."
    \cp $location/hive-conf/* /opt/hive/conf
    nohup hive --service metastore > /var/log/hive-metastore.log 2>&1 &
    if [[ $? -eq 0 ]]; then
        hive -e "show tables;"
        if [[ $? -eq 0 ]]; then
            loggerInfo "Hive installation success!"
            else 
                loggerError "Hive installation failed.......I don't know why."
        fi
        else
                loggerError "Start Hive metastore service failed."
    fi 
}

start() {
    hiveInstall
    postgreInstall
    if [[ -f /opt/.hive-install ]]; then
        hiveConfig
        loggerInfo "Hive installation was finished."
    fi
}

case "$1" in
    start)
        start
        ;;
    *)
        echo $"Usage: $logPrefix {start}"
        RETVAL=3
esac

exit $RETVAL
