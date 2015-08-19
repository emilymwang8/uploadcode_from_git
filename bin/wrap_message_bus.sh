#!/bin/bash

work_dir=$(cd `dirname $0`;pwd)
GLOBAL_TOOlS_DIR=$work_dir/../tools/

. $GLOBAL_TOOlS_DIR/bin/functions.sh


groupId="com.anjuke.service.message"
artifactId="message-bus"
version="1.0.2-SNAPSHOT"
packaging="war"


servers="dev2.aifang.com"
dst_dir="/data1/release/java/message-bus/"
dst_user="www"


repo_dir=/Users/wbsong/projects/anjuke/java/message-bus/
release_mode=0

## build
build_git_project $repo_dir $release_mode
#warfile=`download-file-from-repo $groupId $artifactId $version $packaging`

## download
#print_split_line_less "$warfile download success"

## release_1

#scp_file_to_apps "$servers" "$warfile" "$dst_dir" "$dst_user"

## release_2

