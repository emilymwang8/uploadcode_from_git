#!/bin/bash
## 适用于调用main class的场景


GLOBAL_TOOlS_BIN_DIR=$(cd `dirname $0` > /dev/null;pwd)
. $GLOBAL_TOOlS_BIN_DIR/functions.sh

if [ $# -eq 0 ];then
    print_split_line_less "eg use $0  notify-convert release_new";
    print_split_line_less "eg use $0  notify-convert release_old 201512120101";
    exit 1
fi

env_file=$1
action=$2
to_version=$3

env_file_path=`get_env_file $env_file`
. $env_file_path


##build

if [ "$action" = "release_new" ];then
    rs=`build_git_project $repo_dir $release_mode`
    if [ "$release_mode" = "1" ];then
        to_version=`echo $rs | sed "s#tag-##"`
    fi
elif [ "$action" = "release_old" ];then
    test -n "$to_version"
    exit_if_error $? "old version is empty"
else
    print_split_line_less "error action"
    exit 1
fi

## download
warfile=`download_file_from_repo $groupId $artifactId $pom_version $packaging`
print_split_line_less "$warfile download success"

## release_1
scp_file_to_apps "$servers" "$warfile" "$dst_dir" "$dst_user"

## release_2

