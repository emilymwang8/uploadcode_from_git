#!/bin/bash

work_dir=$(cd `dirname $0` > /dev/null;pwd)
GLOBAL_TOOlS_DIR=$work_dir/../tools/
. $GLOBAL_TOOlS_DIR/bin/functions.sh

env_file=$1
env_file_path=$GLOBAL_TOOlS_DIR/../env/$env_file.sh

test -f "$env_file_path"
exit_if_error $? "$env_file_path not exists"

# groupId="com.anjuke.service.message"
# artifactId="message-bus"

# # release 版本是由 maven release plugin 自动生成的
# version=""
# packaging="war"


# servers="dev2.aifang.com"
# dst_dir="/data1/release/java/message-bus/"
# dst_user="www"


# repo_dir=/Users/wbsong/projects/anjuke/java/message-bus/
# release_mode=1

##build
rs=`build_git_project $repo_dir $release_mode`
if [ "$release_mode" = "1" ];then
    version=`echo $rs | sed "#tag-##"`
fi

## download
warfile=`download-file-from-repo $groupId $artifactId $version $packaging`
print_split_line_less "$warfile download success"

## release_1

scp_file_to_apps "$servers" "$warfile" "$dst_dir" "$dst_user"

## release_2

