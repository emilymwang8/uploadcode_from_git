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
    echo "`date +"%Y-%m-%d %H:%M:%S"` ******************** $1 ***********************";
}

function print_split_line_less {
    echo "`date +"%Y-%m-%d %H:%M:%S"` *** $1 ***";
}

function download-file-from-repo() {
    _groupId=$1
    _artifactId=$2
    _version=$3
    _packaging=$4

    mvn dependency:get -DgroupId=$_groupId -DartifactId=$_artifactId -Dversion=$_version -Dpackaging=$_packaging 1>&2

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
        ssh $_dst_user@$_server "test -d $_dst_dir || mkdir -p $_dst_dir"

        _cmd="scp $_src_file $_dst_user@$_server:$_dst_dir "
        print_split_line_less $_cmd
        $_cmd

        exit_if_error $? "$_cmd error"
    done
}



function launcher_release_war() {
    _warfile=$1

    shift
    _jetty_options=$1

    shift
    _nohup=$1

    if [ -n "$_nohup" ];then
        _nohup="nohup"
        _background="&"
    fi


    _cmd="$_nohup $JAVA_HOME/bin/java -jar $GLOBAL_TOOlS_DIR/lib/jetty-runner-9.3.2.v20150730.jar $_jetty_options > /dev/null 2>&1 $_background"

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
        _release_version=`git tag |grep ^tag- |sort | tail -n 1`
    else
        mvn deploy -Dmaven.test.skip=true 1>&2
    fi

    exit_if_error $? "$_repo_dir deploy error"

    echo $_release_version
}