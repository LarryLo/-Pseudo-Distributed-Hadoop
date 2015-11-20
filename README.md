# Pseudo-Distributed-Hadoop
In this project, you can create a simple pseudo-distributed hadoop, hive and spark computing environment.

# Some Tarbells and RPM need to download before installation.
\- Tarball (Put under tar folder)

1. hadoop-2.7.1.tar
2. apache-hive-1.2.1-bin.tar.gz
3. spark-1.5.1-bin-hadoop2.6.tar

\- RPM (Put under rpm folder)

1. jdk-7u79-linux-x64.rpm

# Preprocedure
1. Use CentOS 6.7 minimal ISO to install OS on Virtual Box.
2. Make sure that the network is connectable to internet with your VM.
3. You have to download all needed tarballs and rpm before installation.

# Installation Steps
1. Put project folder under /opt.
2. $ 1_config_install.sh start
3. $ 2_hadoop_install.sh start
4. $ 3_hive_install.sh start
5. $ 4_spark_install.sh start

After all these steps, you can use a Pseudo-distributed Hadoop environment with Hive(remote mode) and Spark.
