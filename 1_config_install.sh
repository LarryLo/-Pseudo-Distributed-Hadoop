#!/bin/bash

logPrefix="config-install"
baseDir=$(dirname $0)
location=$(pwd)
RETVAL=0

loggerInfo() {
    printf "%s %s %s : %s\n" `date +%Y%m%d-%H:%M:%S` $logPrefix "INFO" "$1"
}

loggerError() {
    printf "%s %s %s : %s\n" `date +%Y%m%d-%H:%M:%S` $logPrefix "ERROR" "$1"
}

sshConf() {
    loggerInfo "Setting ssh configuration"
    sed -i "s#.*StrictHostKeyChecking ask# StrictHostKeyChecking no#g" /etc/ssh/ssh_config
    loggerInfo "Setting sshd configuration"
    sed -i "s@GSSAPIAuthentication .*@GSSAPIAuthentication no@g" /etc/ssh/sshd_config
    sed -i "s@.*UseDNS .*@UseDNS no@g" /etc/ssh/sshd_config
}
sshKeyGen() {
    loggerInfo "Start SSH-KEY-GEN"
    if [[ ! -d /root/.ssh ]]; then
        mkdir /root/.ssh
        chmod 700 /root/.ssh
    fi
    cd /root/.ssh
    ssh-keygen -f id_rsa -t rsa -N ''
    cat /root/.ssh/id_rsa.pub > /root/.ssh/authorized_keys    
}
selinuxClose() {
    sed -i "s/^SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config
}
firewallDown() {
    loggerInfo "Close iptables"
    service iptables stop
    chkconfig iptables off
}

hostConf() {
    loggerInfo "Add Hadoop service host into /etc/hosts"
    ip=$(ifconfig | awk '/eth0/{getline; print substr($2,6);}')
    host=$(hostname)
    master_host="$ip $host"
    echo $master_host >> /etc/hosts
}
jdkInstall() {
    if [[ ! -x /usr/bin/java ]]; then
        yum -y --nogpgcheck localinstall $location/rpm/jdk-7u79-linux-x64.rpm
        JAVA_HOME="/usr/java/jdk1.7.0_79"
        echo "export JAVA_HOME=$JAVA_HOME" >> /etc/profile
        echo "export PATH=$PATH:$JAVA_HOME/bin" >> /etc/profile
        else
            echo "Java exist"
    fi 
}
rebootMaster() {
    loggerInfo "Reboot host immediately......."
    touch /opt/.config_install
    reboot -f
}

start() {
    if [[ ! -f /opt/.config_install ]]; then
        yum -y install wget vim openssh
        firewallDown
        sshConf   
        sshKeyGen
        hostConf
        selinuxClose
        jdkInstall
        rebootMaster 
        else
            echo "Basic configuration has been installed."
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
