#!/bin/bash

logPrefix="hadoop-install"
hadoopTar="hadoop-2.7.1.tar"
hadoopPath="tar/$hadoopTar"
RETVAL=0

loggerInfo() {
    printf "%s %s %s : %s\n" `date +%Y%m%d-%H:%M:%S` $logPrefix "INFO" "$1"
}

loggerError() {
    printf "%s %s %s : %s\n" `date +%Y%m%d-%H:%M:%S` $logPrefix "ERROR" "$1"
}

hadoopInstall() {
    if [[ ! -f /opt/.hadoop-install ]]; then
        tar xvf $hadoopPath -C /opt/
        mv /opt/hadoop-2.7.1 /opt/hadoop
        loggerInfo "Start to set HADOOP_HOME append to PATH"
        sed -i '/export JAVA_HOME=\/usr\/java\/jdk1.7.0_79/a export HADOOP_HOME=\/opt\/hadoop' /etc/profile
        sed -i '/export HADOOP_HOME=\/opt\/hadoop/a export HADOOP_CONF_DIR=\/opt\/hadoop\/etc\/hadoop' /etc/profile
        sed -i '/export HADOOP_CONF_DIR=\/opt\/hadoop\/etc\/hadoop/a export YARN_CONF_DIR=\/opt\/hadoop\/etc\/hadoop' /etc/profile
        sed -i '/^export PATH=/ s/$/:\$HADOOP_HOME\/bin/' /etc/profile
        if [[ $? -eq 0 ]]; then
            touch /opt/.hadoop-install 
            source /etc/profile
        fi
        else 
            loggerInfo "You have installed Hadoop."
    fi
}
hadoopConfig() {
    yes | cp -rf hadoop-conf/* /opt/hadoop/etc/hadoop/
    source /etc/profile
    hdfs namenode -format
    # start hdfs and yarn
    /opt/hadoop/sbin/start-dfs.sh
    /opt/hadoop/sbin/start-yarn.sh
    if [[ $? -eq 0 ]]; then
        hadoop fs -ls /
        loggerInfo "Basic hadoop environment is ready."
    fi
}

start() {
    hadoopInstall
    if [[ -f /opt/.hadoop-install ]]; then
        hadoopConfig
        loggerInfo "Hadoop installation was finished."
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
