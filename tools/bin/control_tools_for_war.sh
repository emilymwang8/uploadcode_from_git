#!/bin/bash
GLOBAL_TOOlS_BIN_DIR=$(cd `dirname $0` > /dev/null;pwd)
. $GLOBAL_TOOlS_BIN_DIR/functions.sh

if [ $# -eq 0 ];then
    print_split_line_less "eg use $0  demo-webmvc restart|start|stop 1.0.0";
    exit 1
fi

env_file=$1
action=$2


env_file_path=`get_env_file $env_file`
. $env_file_path

version=$3

function restart() {
    stop
    sleep 1
    start
}

function start() {
    warfile="$dst_dir/$artifactId-$version.war"
    test -f $warfile
    exit_if_error $? "$warfile not exists"

    launcher_release_war $warfile "$jetty_options"
}

function stop() {
    test -n "$process_identify"
    exit_if_error $? "do not found process_identify"

    _pid=`pgrep -f "Dprocess_identify=$process_identify"`
    if [ $? -eq 0 ];then
        pkill -f -9 "Dprocess_identify=$process_identify"
        exit_if_error $? "kill fail $process_identify"
    fi
}


case $action in
    restart) restart;;
    start) start;;
    stop) stop;;
    *) echo "error action" ;;
esac



