#!/bin/bash

groupId="com.anjuke.demo"
artifactId="webmvc"

# release 版本是由 maven release plugin 自动生成的
version=""
packaging="war"


servers="dev2.aifang.com"
dst_dir="/data1/release/java/demo-webmvc/"
dst_user="www"


repo_dir="/Users/wbsong/projects/self/demo-webmvc/"
release_mode="1"

# 结束进程的时候，按照这个标示符号直接kill
process_identify="$groupId-$artifactId"
jetty_options="--port 2000 "
JAVA_OPTS=""
JAVA_HOME=/usr/local/java/jdk1.8.0_45/