#!/bin/bash

GLOBAL_TOOlS_BIN_DIR=$(cd `dirname $0` > /dev/null;pwd)
. $GLOBAL_TOOlS_BIN_DIR/functions.sh

function helper(){
    print_split_line_less "eg use $0  demo-webmvc release_new_and_restart";
    print_split_line_less "eg use $0  demo-webmvc release_new_only";
    print_split_line_less "eg use $0  demo-webmvc release_old_and_restart release_version";
    exit 1
}

if [ $# -eq 0 ];then
    helper
fi

env_file=$1
action=$2
release_version=$3
pom_version=""

env_file_path=`get_env_file $env_file`
. $env_file_path

version_save_file="/tmp/$env_file.log"


function do_build(){
    rs=`build_git_project $repo_dir $release_mode`
    if [ "$release_mode" = "1" ];then
        ## release 模式，返回的版本号是 1.0.1 类似的
        release_version=`echo $rs | sed "s#tag-##"`
        pom_version=$release_version
    else
        ## snapshot 的版本是时间戳，并且有git tag
        release_version=$rs
        pom_version=$snapshot_pom_version
    fi
    echo $release_version > $version_save_file
}


function do_download_and_copy(){
    if [ -z "$release_version" ];then
        release_version=`read_version_from_file $version_save_file`
    fi

    if [ "$release_mode" = "1" ];then
        pom_version=$release_version
    else
        pom_version=$snapshot_pom_version
    fi

    warfile=`download_file_from_repo $groupId $artifactId $pom_version $packaging`
    test -f "$warfile"
    exit_if_error $? "download error"

    print_split_line_less "$warfile download success"
    if [ "$release_mode" = "1" ];then
        scp_file_to_apps "$servers" "$warfile" "$dst_dir" "$dst_user"
    else
        scp_file_to_apps "$servers" "$warfile" "$dst_dir/$release_version" "$dst_user"
    fi
}


function do_restart(){
    release_war_to_apps "$servers" "$env_file" "$release_version" "$dst_user"
}

case $action in
    release_new_and_restart)
        do_build;
        do_download_and_copy;
        do_restart;
        ;;

    release_new_only)
        do_build;
        do_download_and_copy;
        ;;
    release_old_and_restart)
        do_download_and_copy
        do_restart;
        ;;
    *)
        print_split_line_less "error action $action"
        helper;
        ;;
esac