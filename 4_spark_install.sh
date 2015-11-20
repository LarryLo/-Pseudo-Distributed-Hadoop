#!/bin/bash

logPrefix="spark-install"
location=$(pwd)
sparkTar="spark-1.5.1-bin-hadoop2.6.tar"
sparkPath="tar/$sparkTar"
RETVAL=0

loggerInfo() {
    printf "%s %s %s : %s\n" `date +%Y%m%d-%H:%M:%S` $logPrefix "INFO" "$1"
}

loggerError() {
    printf "%s %s %s : %s\n" `date +%Y%m%d-%H:%M:%S` $logPrefix "ERROR" "$1"
}

sparkInstall() {
    if [[ ! -f /opt/.spark-install ]]; then
        tar xvf $sparkPath -C /opt/
        mv /opt/spark-1.5.1-bin-hadoop2.6 /opt/spark
        loggerInfo "Start to set SPARK_HOME append to PATH"
        sed -i '/export HIVE_HOME=\/opt\/hive/a export SPARK_HOME=\/opt\/spark' /etc/profile
        sed -i '/^export PATH=/ s/$/:\$SPARK_HOME\/bin/' /etc/profile
        if [[ $? -eq 0 ]]; then
            source /etc/profile
            # upload spark-assembly.jar to reduce running time
            hdfs dfs -mkdir -p /user/spark/share/lib
            hdfs dfs -put /opt/spark/lib/spark-assembly-1.5.1-hadoop2.6.0.jar /user/spark/share/lib/spark-assembly.jar
            echo "export SPARK_JAR=hdfs://master1:8020/user/spark/share/lib/spark-assembly.jar" >> /etc/profile
            loggerInfo "Spark installation is finished."
            touch /opt/.spark-install
        fi
        else 
            loggerInfo "Spark has been installed."
    fi
}
sparkWithHive() {
    loggerInfo "Start to integrate SparkSQL with Hive."
    cp /opt/hive/conf/hive-site.xml /opt/spark/conf/
}

#hiveOnSpark() {
#    # Reference from: https://cwiki.apache.org/confluence/display/Hive/Hive+on+Spark%3A+Getting+Started
#    loggerInfo "Start to integrate Spark and Hive."
#    hive -e "set spark.home=/opt/spark;"
#    ln -s /opt/spark/lib/spark-assembly-1.5.1-hadoop2.6.0.jar /opt/hive/lib/spark-assembly-1.5.1-hadoop2.6.0.jar
#    hive -e "set hive.execution.engine=spark;"
#}

start() {
    sparkInstall
    sparkWithHive 
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
