#!/bin/bash

GLOBAL_TOOlS_BIN_DIR=$(cd `dirname $0` > /dev/null;pwd)
. $GLOBAL_TOOlS_BIN_DIR/functions.sh

if [ $# -eq 0 ];then
    print_split_line_less "eg use $0  demo-webmvc restart|start|stop 1.0.0";
    exit 1
fi

env_file=$1
action=$2
release_version=$3

env_file_path=`get_env_file $env_file`
. $env_file_path

test -d "$log_dir" || mkdir -p "$log_dir"
exit_if_error $? "create log_dir $log_dir error"


function restart() {
    stop
    sleep 1
    start
}

function start() {
    if [ "$release_mode" -eq "0" ];then
        warfile="$dst_dir/$release_version/$artifactId-$snapshot_pom_version.war"
    else
        warfile="$dst_dir/$artifactId-$release_version.war"
    fi
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



