#!/bin/bash

function exit_if_error {
    error_code=$1
    error_message=$2
    if [ $error_code -ne 0 ];then
        print_split_line_less $error_message;
        exit 1;
    fi
}

function print_split_line_more {
    echo "`date +"%Y-%m-%d %H:%M:%S"` ******************** $@ ***********************";
}

function print_split_line_less {
    echo "`date +"%Y-%m-%d %H:%M:%S"` *** $@ ***";
}


function get_env_file () {
    env_file=$1
    env_file_path=$GLOBAL_TOOlS_BIN_DIR/../../env/$env_file.sh
    test -f "$env_file_path"
    exit_if_error $? "$env_file_path not exists"

    echo $env_file_path;
}

function download_file_from_repo() {
    _groupId=$1
    _artifactId=$2
    _version=$3
    _packaging=$4

    call_and_print_cmd "mvn dependency:get -DgroupId=$_groupId -DartifactId=$_artifactId -Dversion=$_version -Dpackaging=$_packaging" 1>&2

    exit_if_error $? "download $@ error";
    _groupPath=`echo $_groupId | sed "s#\.#/#g"`

    file="$HOME/.m2/repository/$_groupPath/$_artifactId/$_version/$_artifactId-$_version.$_packaging"

    test -f $file
    exit_if_error $? "$file not exists"
    echo $file
}

function scp_file_to_apps() {
    _servers=$1
    _src_file=$2
    _dst_dir=$3
    _dst_user=$4

    if [ -z "$_dst_user" ];then
        _dst_user="evans"
    fi

    for _server in "${_servers[@]}"
    do
        call_and_print_cmd ssh $_dst_user@$_server "test -d $_dst_dir || mkdir -p $_dst_dir"
        call_and_print_cmd scp $_src_file $_dst_user@$_server:$_dst_dir
    done
}

function release_war_to_apps() {
    _servers=$1
    _env_file=$2
    _release_version=$3
    _dst_user=$4
    if [ -z "$_dst_user" ];then
        _dst_user="evans"
    fi

    for _server in "${_servers[@]}"
    do
        call_and_print_cmd ssh $_dst_user@$_server "/home/www/bin/java-deploy-tools/tools/bin/control_tools_for_war.sh $_env_file restart $_release_version > /dev/null 2>&1 &"
    done
}


function scp_file_and_unpack_to_apps() {
    _servers=$1
    _src_file=$2
    _dst_dir=$3
    _dst_user=$4
    _version=$5

    if [ -z "$_dst_user" ];then
        _dst_user="evans"
    fi

    for _server in "${_servers[@]}"
    do
        _dst_unpack_dir="$_dst_dir/$_version"
        call_and_print_cmd "ssh $_dst_user@$_server \"test -d $_dst_unpack_dir || mkdir -p $_dst_unpack_dir\""
        call_and_print_cmd "scp $_src_file $_dst_user@$_server:$_dst_dir "

        _extension=${_src_file##*.}
        _unpack_cmd=""

        case "$_extension" in
            zip ) _unpack_cmd=" unzip -d $_dst_unpack_dir $_src_file" ;;
            gz ) _unpack_cmd=" tar -C $_dst_unpack_dir -xzf $_src_file" ;;
            bz2 ) _unpack_cmd=" tar -C $_dst_unpack_dir -xjf $_src_file" ;;
            * ) exit_if_error 1 " unknow file formart $_src_file" ;;
        esac

        call_and_print_cmd "ssh $_dst_user@$_server \"$_unpack_cmd\""
    done
}

function call_and_print_cmd(){
    print_split_line_less $@
    $@
    exit_if_error $? "$@ error"
}

function call_and_print_cmd_backend(){
    print_split_line_less $@
    nohup $@ &
    exit_if_error $? "$@ error"
}


function launcher_release_war() {
    _warfile=$1

    shift
    _jetty_options=$1

    shift
    _process_identify=$1

    test -f $_warfile
    exit_if_error $? "$_warfile not exits"

    cd `dirname $_warfile`

    test -n "$JAVA_HOME"
    exit_if_error $? "JAVA_HOME not exits"

    call_and_print_cmd_backend $JAVA_HOME/bin/java -Dprocess_identify=$process_identify $JAVA_OPTS -jar $GLOBAL_TOOlS_BIN_DIR/../lib/jetty-runner-9.3.2.v20150730.jar $_jetty_options $_warfile > $sysout_file 2>&1
}

function build_git_project() {
    _repo_dir=$1

    # 是否使用maven 的 release 插件
    _release_mode=$2
    _release_version=""

    test -d "$_repo_dir"
    exit_if_error $? "$_repo_dir not exists "


    cd $_repo_dir

    git reset --hard HEAD 1>&2
    git pull --rebase 1>&2
    exit_if_error $? "$_repo_dir pull error "

    # 后面的标准流程都是 deploy 或者 release，包括 war项目 && tar.bz2 项目

    if [ "$_release_mode" = "1" ];then
        mvn -B release:prepare 1>&2
        exit_if_error $? "prepare error"
        mvn -B release:perform 1>&2
        exit_if_error $? "perform error"
        git fetch origin 1>&2
        _release_version=`git tag | awk -F'[.]' '{print $0,$3}'|sort -nk2 | tail -n1 | awk '{print $1}'`
    else
        _release_version=`date +%Y%m%d%H%M`
        git tag $_release_version 1>&2
        mvn deploy -Dmaven.test.skip=true 1>&2
    fi

    exit_if_error $? "$_repo_dir deploy error"

    echo $_release_version
}

function read_version_from_file(){
    _version_file=$1

    test -f "$_version_file"
    exit_if_error $? "$_version_file no exists"

    _version=`cat $_version_file`

    read -n1 -p "release version at $_version ?[Yn] yes enter  " action
    if [ "$action" = "n" ];then
        exit 1;
    fi

    echo $_version
}