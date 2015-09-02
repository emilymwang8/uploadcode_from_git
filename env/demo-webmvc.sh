#!/bin/bash

groupId="com.anjuke.demo"
artifactId="webmvc"

# release 版本有 mvn release:prepare 自动生成
snapshot_pom_version="1.0.13-SNAPSHOT"
packaging="war"


servers="dev2.aifang.com"
dst_dir="/data1/release/java/demo-webmvc/"
dst_user="www"


repo_dir="/Users/wbsong/projects/self/demo-webmvc/"
release_mode="1"

log_dir="/data1/logs/demo-webmvc"
sysout_file=$log_dir/sysout.log


# 结束进程的时候，按照这个标示符号直接kill
process_identify="$groupId-$artifactId"
jetty_options="--port 2000 --out $log_dir/$artifactId.out.yyyy_mm_dd --log $log_dir/$artifactId.request.yyyy_mm_dd"
JAVA_OPTS="-Xmx1024m -Xms1024M -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCDateStamps -Xloggc:$log_dir/$artifactId.gc.log."`date +"%Y%m%d-%H%M"`

test -d /usr/local/java/jdk1.8.0_45/ && export JAVA_HOME=/usr/local/java/jdk1.8.0_45/

#launcher_jar="lib/xx.jar"
