#!/bin/bash

cp -R $SRC_DIR $PREFIX

cp $SRC_DIR/conda/.env.conda $PREFIX/.env
chmod 666 $PREFIX/logstash/sandbox/settings/logstash.yml

mkdir -p $PREFIX/mydig-projects/.es/data
