#!/bin/bash

groupId="com.anjuke.mobile"
artifactId="notify-convert"

# pom_release 版本是由 maven release plugin 自动生成的
pom_version="1.0.1-SNAPSHOT"
packaging="tar.bz2"


servers="dev2.aifang.com"
dst_dir="/data1/release/java/notify-convert/"
dst_user="www"


repo_dir="/Users/wbsong/projects/anjuke/java/notify/notify-convert"
release_mode="0"

# 结束进程的时候，按照这个标示符号直接kill
process_identify="$groupId-$artifactId"

JAVA_OPTS=""

test -f /usr/local/java/jdk1.8.0_45/ && JAVA_HOME=/usr/local/java/jdk1.8.0_45/

launcher_jar="lib/xx.jar"