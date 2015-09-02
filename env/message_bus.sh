#!/bin/bash

groupId="com.anjuke.service.message"
artifactId="message-bus"

# release 版本有 mvn release:prepare 自动生成
snapshot_pom_version="1.0.13-SNAPSHOT"
packaging="war"


servers="dev2.aifang.com"
dst_dir="/data1/release/java/message-bus/"
dst_user="www"


repo_dir="/Users/wbsong/projects/anjuke/java/message-bus"
release_mode="1"

log_dir="/data1/logs/message-bus"
sysout_file=$log_dir/sysout.log


# 结束进程的时候，按照这个标示符号直接kill
process_identify="$groupId-$artifactId"
jetty_options="--port 1901 --out $log_dir/$artifactId.out.yyyy_mm_dd --log $log_dir/$artifactId.request.yyyy_mm_dd"
JAVA_OPTS="-Dlogback.configurationFile=/home/www/config/java/message-bus-logback.xml -Dconfig.path=/home/www/config/java/message-bus-config.json -Xmx1024m -Xms1024M -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCDateStamps -Xloggc:$log_dir/$artifactId.gc.log."`date +"%Y%m%d-%H%M"`

test -d /usr/local/java/jdk1.8.0_45/ && export JAVA_HOME=/usr/local/java/jdk1.8.0_45/
