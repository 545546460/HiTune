#!/bin/bash 
DIR=`dirname $0`


CONF_FILE=

CHUKWA_HITUNE_DIST="chukwa-hitune-dist"
INSTALL="cp -ira"

PRIVATE_FOUR_SPACEPRIVATE_TAB="    "
PRIVATE_TAB="\t"



# ./install.sh -f conf_file
usage(){
    echo "$0 -f conf_file -r cluster_role";
    echo -e "${PRIVATE_FOUR_SPACEPRIVATE_TAB}-f configuration file.${PRIVATE_TAB}You can copy .hitune.conf.template file and edit it properly into a configuration file"
    echo -e "${PRIVATE_FOUR_SPACEPRIVATE_TAB}-h${PRIVATE_TAB}show this"
    exit 1;
}

check(){
    test $1 != 0 && echo "[Error] installation failed" && exit 1;
}

while [ $# -ge 1 ]; do
    case $1 in
    -f)
        CONF_FILE=$2
        shift
        ;;
    -r)
        CLUSTER_ROLE=$2
        shift
        ;;
    *)
        usage
        ;;
    esac
    shift
done


if [ "$CONF_FILE" = "" ];then
    echo "[Error]conf_file is empty." 1>&2
    usage;
fi

if [ -z $CONF_FILE ];then
    echo "[Error]conf_file doesn't exist" 1>&2
    usage;
fi

. $CONF_FILE
CLUSTER_ROLE=${CLUSTER_ROLE:-"$_CLUSTER_ROLE"}
# install && print out installation steps
# 1. copy to chukwa_home
# 2. copy neccessary libraries to hadoop
# 3. if it is a "hadoop_cluster" , copy neccessary files to hadoop, recommend the end-user to restart the hadoop_cluster
SRC=`cd $DIR/; pwd`
echo "$INSTALL $SRC $_INSTALL_DIR"
$INSTALL $SRC $_INSTALL_DIR 1> /dev/null
check $?

echo "$INSTALL $SRC/share/chukwa/lib/json*.jar $_CHUKWA_CLUSTER_HADOOP_HOME/lib"
$INSTALL $SRC/share/chukwa/lib/json*.jar $_CHUKWA_CLUSTER_HADOOP_HOME/lib 1> /dev/null
check $?

test -e $_CHUKWA_CLUSTER_HADOOP_CONF_DIR/hadoop-env.sh.backup && \
echo "mv -i $_CHUKWA_CLUSTER_HADOOP_CONF_DIR/hadoop-env.sh.backup $_CHUKWA_CLUSTER_HADOOP_CONF_DIR/hadoop-env.sh" && \
mv $_CHUKWA_CLUSTER_HADOOP_CONF_DIR/hadoop-env.sh.backup $_CHUKWA_CLUSTER_HADOOP_CONF_DIR/hadoop-env.sh

echo "$INSTALL $_CHUKWA_CLUSTER_HADOOP_CONF_DIR/hadoop-env.sh $_CHUKWA_CLUSTER_HADOOP_CONF_DIR/hadoop-env.sh.backup" 
$INSTALL $_CHUKWA_CLUSTER_HADOOP_CONF_DIR/hadoop-env.sh $_CHUKWA_CLUSTER_HADOOP_CONF_DIR/hadoop-env.sh.backup
check $?

echo "cat $SRC/etc/chukwa/hitune-hadoop-env.sh >> $_CHUKWA_CLUSTER_HADOOP_CONF_DIR/hadoop-env.sh "
cat $SRC/etc/chukwa/hitune-hadoop-env.sh >> $_CHUKWA_CLUSTER_HADOOP_CONF_DIR/hadoop-env.sh 
check $?


echo "$INSTALL $SRC/share/chukwa/chukwa*.jar $_CHUKWA_CLUSTER_HADOOP_HOME/lib"
$INSTALL $SRC/share/chukwa/chukwa*.jar $_CHUKWA_CLUSTER_HADOOP_HOME/lib 1> /dev/null
check $?

echo "$INSTALL $SRC/hitune/HiTune*.jar $_CHUKWA_CLUSTER_HADOOP_HOME/lib"
$INSTALL $SRC/hitune/HiTune*.jar $_CHUKWA_CLUSTER_HADOOP_HOME/lib 1> /dev/null
check $?

echo "$INSTALL $SRC/etc/chukwa/hadoop-log4j.properties $_CHUKWA_CLUSTER_HADOOP_HOME/log4j.properties"
$INSTALL $SRC/etc/chukwa/hadoop-log4j.properties $_CHUKWA_CLUSTER_HADOOP_HOME/log4j.properties 1> /dev/null
check $?

echo "$INSTALL $SRC/etc/chukwa/hadoop-metrics2.properties $_CHUKWA_CLUSTER_HADOOP_HOME"
$INSTALL $SRC/etc/chukwa/hadoop-metrics2.properties $_CHUKWA_CLUSTER_HADOOP_HOME 1> /dev/null
check $?
    



