#!/bin/bash

cp -R $SRC_DIR $BUILD_PREFIX

cp $SRC_DIR/conda/.env.conda $BUILD_PREFIX/.env
chmod 666 $BUILD_PREFIX/logstash/sandbox/settings/logstash.yml

mkdir -p $BUILD_PREFIX/mydig-projects/.es/data
