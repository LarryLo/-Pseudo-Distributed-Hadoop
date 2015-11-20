#!/bin/bash
logPrefix="spark-example"
RETVAL=0

source /etc/profile

loggerInfo() {
    printf "%s %s %s : %s\n" `date +%Y%m%d-%H:%M:%S` $logPrefix "INFO" "$1"
}

loggerError() {
    printf "%s %s %s : %s\n" `date +%Y%m%d-%H:%M:%S` $logPrefix "ERROR" "$1"
}

sparkOnYarn() {
    loggerInfo "Start SparkPi example on YARN"  
     
    spark-submit --class org.apache.spark.examples.SparkPi --master yarn --deploy-mode client /opt/spark/lib/spark-examples-1.5.1-hadoop2.6.0.jar 10 
}





case "$1" in
    spark-on-yarn)
        sparkOnYarn
        ;;
    *)
        echo $"Usage: $logPrefix {spark-on-yarn|}"        
        RETVAL=3 
esac

exit $RETVAL

